// src/middleware/bid.js
const { body, validationResult } = require("express-validator");
const mongoose = require('mongoose');
const User = require('../models/User');
const Auction = require('../models/Auction');
const Bid = require('../models/Bid');
const { ethers } = require("ethers");
const { vndToWei, weiToVnd } = require('../utils/conversion');

const validateBidRequest = [
  body("auction_id").isMongoId().withMessage("auction_id must be a valid ObjectId"),
  body("amount_vnd").isFloat({ min: 1 }).withMessage("amount_vnd must be > 0"),
  body("signature").isString().notEmpty().withMessage("signature is required"),
  body("nonce").isInt({ min: 0 }).withMessage("nonce must be a non-negative integer"),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });
    next();
  },
];

const processBid = async (req, res, next) => {
  try {
    const { auction_id, amount_vnd, signature, nonce } = req.body;
    const userId = req.user.id;

    const [user, auction] = await Promise.all([
      User.findById(userId),
      Auction.findById(auction_id)
    ]);

    if (!user) return res.status(404).json({ error: 'User not found' });
    if (!auction) return res.status(404).json({ error: 'Auction not found' });
    if (auction.status !== 'ACTIVE') return res.status(400).json({ error: 'Auction is not active' });
    if (new Date() > auction.end_time) return res.status(400).json({ error: 'Auction has ended' });

    const amountWei = vndToWei(amount_vnd);

    // Kiểm tra nonce
    if (nonce <= user.last_nonce) {
      return res.status(400).json({ error: 'Invalid nonce - replay attack detected' });
    }

    // Kiểm tra giá bid có đủ cao không
    const currentPrice = ethers.BigNumber.from(auction.current_price.toString());
    const stepPrice = ethers.BigNumber.from(auction.step_price.toString());
    const minBidWei = currentPrice.add(stepPrice);

    if (ethers.BigNumber.from(amountWei).lt(minBidWei)) {
      return res.status(400).json({
        error: 'Bid amount too low',
        min_bid_vnd: weiToVnd(minBidWei.toString()),
        required_increase_vnd: weiToVnd(stepPrice.toString())
      });
    }

    // Kiểm tra số dư khả dụng
    const balanceEth = ethers.BigNumber.from(user.balance_eth.toString());
    const lockedEth = ethers.BigNumber.from(user.locked_eth.toString());
    const availableEth = balanceEth.sub(lockedEth);
    const bidWeiBN = ethers.BigNumber.from(amountWei);

    if (availableEth.lt(bidWeiBN)) {
      return res.status(400).json({
        error: 'Insufficient available balance',
        available_vnd: weiToVnd(availableEth.toString()),
        required_vnd: weiToVnd(bidWeiBN.toString())
      });
    }

    req.bidData = {
      user,
      auction,
      amountWei,
      amountVnd: amount_vnd,
      signature,
      nonce
    };

    next();
  } catch (error) {
    console.error('Error in processBid middleware:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

const handleBidLocking = async (req, res, next) => {
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    const { user, auction, amountWei, amountVnd, nonce } = req.bidData;

    // === 1. Khóa tiền người bid mới ===
    const currentLocked = BigInt(user.locked_eth || "0");
    const bidWeiBigInt = BigInt(amountWei);
    const newLocked = (currentLocked + bidWeiBigInt).toString();

    await User.findByIdAndUpdate(user._id, {
      $set: {
        locked_eth: newLocked,
        last_nonce: nonce
      }
    }, { session });

    let previousBidder = null;

    // === 2. Mở khóa người bị vượt giá (nếu có) ===
    if (
      auction.highest_bidder_id &&
      auction.highest_bidder_id.toString() !== user._id.toString()
    ) {
      previousBidder = auction.highest_bidder_id;

      // Lấy user cũ để tính locked_eth mới
      const oldUser = await User.findById(auction.highest_bidder_id).session(session);
      if (!oldUser) {
        throw new Error("Previous bidder not found");
      }

      const oldPriceBigInt = BigInt(auction.current_price.toString());
      const oldLockedBigInt = BigInt(oldUser.locked_eth || "0");
      const unlockedAmount = oldLockedBigInt - oldPriceBigInt;
      const newOldLocked = unlockedAmount >= 0n ? unlockedAmount.toString() : "0";

      await User.findByIdAndUpdate(auction.highest_bidder_id, {
        $set: { locked_eth: newOldLocked }
      }, { session });

      // Đánh dấu các bid cũ là OUTBID
      await Bid.updateMany(
        { auction_id: auction._id, status: 'WINNING' },
        { status: 'OUTBID' },
        { session }
      );
    }

    // === 3. Cập nhật auction ===
    await Auction.findByIdAndUpdate(auction._id, {
      $set: {
        current_price: amountWei,
        highest_bidder_id: user._id
      }
    }, { session });

    // === 4. Tạo bản ghi bid mới ===
    const newBid = new Bid({
      auction_id: auction._id,
      user_id: user._id,
      amount_wei: amountWei,
      amount_vnd: amountVnd,
      signature: req.body.signature,
      nonce: nonce,
      status: 'WINNING'
    });
    await newBid.save({ session });

    await session.commitTransaction();

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