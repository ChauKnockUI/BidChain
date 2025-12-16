// src/middleware/bid.js
const { body, validationResult } = require("express-validator");
const mongoose = require('mongoose');
const User = require('../models/User');
const Auction = require('../models/Auction');
const Bid = require('../models/Bid');
const { ethers } = require("ethers");
const { vndToWei, weiToVnd } = require('../utils/conversion');
const { contract } = require('../blockchain/contract');
const { signBid } = require('../utils/eip712');

const validateBidRequest = [
  body("auction_id").isMongoId().withMessage("auction_id must be a valid ObjectId"),
  body("amount_vnd").isFloat({ min: 1 }).withMessage("amount_vnd must be > 0"),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      console.error('Bid validation failed:', errors.array());
      return res.status(400).json({ errors: errors.array() });
    }
    next();
  },
];

const processBid = async (req, res, next) => {
  try {
    const { auction_id, amount_vnd } = req.body;
    const userId = req.user.id;

    console.log(`Processing bid: User ${userId}, Auction ${auction_id}, Amount ${amount_vnd} VND`);

    const [user, auction] = await Promise.all([
      User.findById(userId).select('+encrypted_private_key'),
      Auction.findById(auction_id)
    ]);

    if (!user) {
      console.error(`Bid failed: User ${userId} not found`);
      return res.status(404).json({ error: 'User not found' });
    }
    if (!auction) {
      console.error(`Bid failed: Auction ${auction_id} not found`);
      return res.status(404).json({ error: 'Auction not found' });
    }
    if (auction.status !== 'ACTIVE') {
      console.error(`Bid failed: Auction ${auction_id} status is ${auction.status}`);
      return res.status(400).json({ error: 'Auction is not active' });
    }
    if (new Date() > auction.end_time) {
      console.error(`Bid failed: Auction ${auction_id} has ended`);
      return res.status(400).json({ error: 'Auction has ended' });
    }

    // Check if bidder is the auction creator
    if (auction.seller_id && auction.seller_id.toString() === userId.toString()) {
      console.error(`Bid failed: User ${userId} is the auction creator`);
      return res.status(403).json({
        error: 'Auction creator cannot bid on their own auction',
        message: 'Bạn không thể đấu giá trên phiên đấu giá của chính mình'
      });
    }

    const amountWei = vndToWei(amount_vnd);
    const nonce = (user.last_nonce || 0) + 1;
    const timestamp = Math.floor(Date.now() / 1000);

    // Sign bid server-side
    let signature;
    try {
      signature = await signBid(user, auction_id, amountWei, nonce, timestamp);
      console.log(`Bid signed successfully`);
    } catch (error) {
      console.error('Bid signing error:', error);
      return res.status(500).json({ error: 'Failed to sign bid', details: error.message });
    }

    // Verify signature on-chain
    try {
      const isValid = await contract.verifyBidSignature(
        auction_id,
        ethers.BigNumber.from(amountWei),
        nonce,
        timestamp,
        signature,
        user.wallet_address
      );

      if (!isValid) {
        console.error(`Bid failed: Signature verification failed`);
        return res.status(500).json({ error: 'Signature verification failed' });
      }
      console.log(`Signature verified successfully`);
    } catch (error) {
      console.error('Signature verification error:', error);
      return res.status(500).json({ error: 'Signature verification failed', details: error.message });
    }

    // Check bid amount
    const currentPrice = ethers.BigNumber.from(auction.current_price.toString());
    const stepPrice = ethers.BigNumber.from(auction.step_price.toString());
    const minBidWei = currentPrice.add(stepPrice);

    if (ethers.BigNumber.from(amountWei).lt(minBidWei)) {
      const minBidVnd = weiToVnd(minBidWei.toString());
      console.error(`Bid failed: Amount ${amount_vnd} VND too low, minimum is ${minBidVnd} VND`);
      return res.status(400).json({
        error: 'Bid amount too low',
        min_bid_vnd: minBidVnd,
        required_increase_vnd: weiToVnd(stepPrice.toString())
      });
    }

    // Check available balance
    const balanceEth = ethers.BigNumber.from(user.balance_eth.toString());
    const lockedEth = ethers.BigNumber.from(user.locked_eth.toString());
    const availableEth = balanceEth.sub(lockedEth);
    const bidWeiBN = ethers.BigNumber.from(amountWei);

    if (availableEth.lt(bidWeiBN)) {
      console.error(`Bid failed: Insufficient balance. Available: ${weiToVnd(availableEth.toString())} VND, Required: ${amount_vnd} VND`);
      return res.status(400).json({
        error: 'Insufficient available balance',
        available_vnd: weiToVnd(availableEth.toString()),
        required_vnd: amount_vnd
      });
    }

    req.bidData = {
      user,
      auction,
      amountWei,
      amountVnd: amount_vnd,
      signature,
      nonce,
      timestamp
    };

    next();
  } catch (error) {
    console.error('Error in processBid middleware:', error);
    res.status(500).json({ error: 'Internal server error', details: error.message });
  }
};

const handleBidLocking = async (req, res, next) => {
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    const { user, auction, amountWei, amountVnd, signature, nonce, timestamp } = req.bidData;

    console.log(`Locking funds: User ${user._id}, Amount ${amountVnd} VND`);

    const currentLocked = BigInt(user.locked_eth || "0");
    const bidWeiBigInt = BigInt(amountWei);
    let newLockedBigInt = currentLocked + bidWeiBigInt;

    // If same user is outbidding themselves, subtract the old bid amount immediately
    if (auction.highest_bidder_id && auction.highest_bidder_id.toString() === user._id.toString()) {
      const oldPriceBigInt = BigInt(auction.current_price.toString());
      newLockedBigInt = newLockedBigInt - oldPriceBigInt;
      console.log(`User outbidding themselves. Net lock change: +${weiToVnd((bidWeiBigInt - oldPriceBigInt).toString())} VND`);
    }

    const newLocked = newLockedBigInt >= 0n ? newLockedBigInt.toString() : "0";

    await User.findByIdAndUpdate(user._id, {
      $set: {
        locked_eth: newLocked,
        last_nonce: nonce
      }
    }, { session });

    let previousBidder = null;

    if (auction.highest_bidder_id) {
      previousBidder = auction.highest_bidder_id;

      // Only unlock previous bidder if it's a DIFFERENT user
      if (auction.highest_bidder_id.toString() !== user._id.toString()) {
        const oldUser = await User.findById(auction.highest_bidder_id).session(session);
        if (oldUser) {
          const oldPriceBigInt = BigInt(auction.current_price.toString());
          const oldLockedBigInt = BigInt(oldUser.locked_eth || "0");
          const unlockedAmount = oldLockedBigInt - oldPriceBigInt;
          const newOldLocked = unlockedAmount >= 0n ? unlockedAmount.toString() : "0";

          console.log(`Unlocking previous bidder ${previousBidder}: ${weiToVnd(oldPriceBigInt.toString())} VND`);

          await User.findByIdAndUpdate(auction.highest_bidder_id, {
            $set: { locked_eth: newOldLocked }
          }, { session });
        }
      }

      // ALWAYS mark old bids as OUTBID, regardless of who the bidder was
      await Bid.updateMany(
        { auction_id: auction._id, status: 'WINNING' },
        { status: 'OUTBID' },
        { session }
      );
    }

    await Auction.findByIdAndUpdate(auction._id, {
      $set: {
        current_price: amountWei,
        highest_bidder_id: user._id
      }
    }, { session });

    const newBid = new Bid({
      auction_id: auction._id,
      user_id: user._id,
      amount_wei: amountWei,
      amount_vnd: amountVnd,
      signature: signature,
      nonce: nonce,
      timestamp: timestamp,
      verified_on_chain: true,
      status: 'WINNING'
    });
    await newBid.save({ session });

    await session.commitTransaction();

    console.log(`✅ Bid placed successfully: ${amountVnd} VND on auction ${auction._id}`);

    // ========== RECORD BID ON BLOCKCHAIN ==========
    // This happens AFTER MongoDB transaction to ensure bid is valid
    if (auction.blockchain_id && auction.contract_address) {
      try {
        const { walletFromPrivateKey, provider } = require('../blockchain/contract');
        const fs = require('fs');
        const path = require('path');

        // Calculate signature hash for on-chain recording
        const signatureHash = ethers.utils.keccak256(signature);

        // Get deployer wallet to sign transaction
        const deployer = walletFromPrivateKey(process.env.DEPLOYER_PRIVATE_KEY);

        // Load ABI
        const abiPath = process.env.CONTRACT_ABI_PATH || './abi/Auction.json';
        const abiRaw = fs.readFileSync(path.resolve(abiPath), 'utf8');
        const abiParsed = JSON.parse(abiRaw);
        const abi = abiParsed.abi || abiParsed;

        // Create contract instance using AUCTION'S contract_address (not global!)
        const auctionContract = new ethers.Contract(auction.contract_address, abi, provider);

        console.log(`📝 Recording bid on blockchain for auction ${auction.blockchain_id}...`);
        console.log(`   Contract: ${auction.contract_address}`);

        // Call smart contract recordBid function
        const tx = await auctionContract.connect(deployer).recordBid(
          auction.blockchain_id,           // Auction ID on blockchain
          user.wallet_address,             // Bidder address
          ethers.BigNumber.from(amountWei), // Amount in Wei
          signatureHash                    // Hash of EIP-712 signature
        );

        console.log(`⏳ Waiting for transaction confirmation: ${tx.hash}`);
        const receipt = await tx.wait();

        console.log(`✅ Bid recorded on-chain!`);
        console.log(`   TX Hash: ${tx.hash}`);
        console.log(`   Block: ${receipt.blockNumber}`);

        // Get the bid hash from the event
        const bidRecordedEvent = receipt.events?.find(e => e.event === 'BidRecorded');
        const onChainBidHash = bidRecordedEvent?.args?.bidHash;

        // Update bid document with on-chain info
        await Bid.findByIdAndUpdate(newBid._id, {
          on_chain_tx_hash: tx.hash,
          on_chain_block: receipt.blockNumber,
          on_chain_bid_hash: onChainBidHash
        });

      } catch (onChainError) {
        // Log error but don't fail the request - bid is still valid in MongoDB
        console.error('⚠️ Failed to record bid on blockchain (bid still valid):', onChainError.message);
      }
    } else {
      console.log('ℹ️ Auction has no blockchain_id, skipping on-chain recording');
    }

    // ========== ON-CHAIN BALANCE LOCK/UNLOCK ==========
    // Lock new bid amount and unlock previous bidder on BidChainWallet contract
    try {
      const { lockUserBalance, unlockUserBalance, isWalletContractAvailable } = require('../blockchain/wallet-contract');

      if (isWalletContractAvailable() && auction.blockchain_id) {
        // Lock current bidder's funds on-chain
        console.log(`🔒 Locking ${amountWei} wei on-chain for user ${user.wallet_address}...`);
        await lockUserBalance(user.wallet_address, auction.blockchain_id, amountWei);
        console.log(`✅ On-chain lock successful!`);

        // Unlock previous bidder if different user
        if (previousBidder && previousBidder.toString() !== user._id.toString()) {
          const oldUser = await User.findById(previousBidder);
          if (oldUser && oldUser.wallet_address) {
            const oldPriceWei = auction.current_price.toString();
            console.log(`🔓 Unlocking ${oldPriceWei} wei on-chain for previous bidder ${oldUser.wallet_address}...`);
            await unlockUserBalance(oldUser.wallet_address, auction.blockchain_id, oldPriceWei);
            console.log(`✅ On-chain unlock successful!`);
          }
        }
      }
    } catch (walletError) {
      console.error('⚠️ On-chain balance lock/unlock failed (bid still valid):', walletError.message);
    }

    req.bidResult = {
      bid: newBid,
      previousBidder
    };

    next();
  } catch (error) {
    await session.abortTransaction();
    console.error('Bid locking failed:', error);
    res.status(500).json({
      error: 'Failed to place bid',
      details: error.message
    });
  } finally {
    session.endSession();
  }
};

module.exports = { validateBidRequest, processBid, handleBidLocking };