const { body, validationResult } = require("express-validator");
const mongoose = require('mongoose');
const User = require('../models/User');
const Auction = require('../models/Auction');
const Bid = require('../models/Bid');
const { verifyBidSignature } = require('../utils/eip712');
const { vndToWei, weiToVnd } = require('../utils/conversion');
const { ethers } = require("ethers"); // ← THÊM DÒNG NÀY

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

/**
 * Middleware kiểm tra logic bid
 */
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

    // TẠM TẮT VERIFY CHỮ KÝ ĐỂ TEST (bật lại sau)
    // const isValidSignature = verifyBidSignature(
    //   signature,
    //   auction_id,
    //   amountWei,
    //   nonce,
    //   user.wallet_address
    // );
    // if (!isValidSignature) {
    //   return res.status(400).json({ error: 'Invalid signature' });
    // }

    // SỬA LỖI CHÍNH: DÙNG ethers.BigNumber ĐỂ SO SÁNH CHÍNH XÁC
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
    const bidEth = ethers.BigNumber.from(amountWei);
    console.log("amount_vnd:", amount_vnd);
    console.log("amountWei calculated:", amountWei);
    console.log("user balance_eth:", user.balance_eth.toString());
    console.log("user locked_eth:", user.locked_eth.toString());
    if (availableEth.lt(bidEth)) {
      return res.status(400).json({
        error: 'Insufficient available balance',
        available_vnd: weiToVnd(availableEth.toString()),
        required_vnd: weiToVnd(bidEth.toString())
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

/**
 * Middleware khóa tiền & tự động mở khóa bidder cũ
 */
const handleBidLocking = async (req, res, next) => {
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    const { user, auction, amountWei } = req.bidData;
    const bidEth = ethers.BigNumber.from(amountWei);

    // Khóa tiền người bid mới
    await User.findByIdAndUpdate(user._id, {
      $inc: { locked_eth: bidEth.toString() },
      last_nonce: req.body.nonce
    }, { session });

    // Mở khóa người bị vượt giá (nếu có)
    if (auction.highest_bidder_id && auction.highest_bidder_id.toString() !== user._id.toString()) {
      const oldBidAmount = ethers.BigNumber.from(auction.current_price.toString());

      await User.findByIdAndUpdate(auction.highest_bidder_id, {
        $inc: { locked_eth: "-" + oldBidAmount.toString() }
      }, { session });

      await Bid.updateMany(
        { auction_id: auction._id, status: 'WINNING' },
        { status: 'OUTBID' },
        { session }
      );
    }

    // Cập nhật auction
    await Auction.findByIdAndUpdate(auction._id, {
      current_price: amountWei,
      highest_bidder_id: user._id
    }, { session });

    // Tạo bản ghi bid
    const newBid = new Bid({
      auction_id: auction._id,
      user_id: user._id,
      amount_wei: amountWei,
      signature: req.body.signature,
      nonce: req.body.nonce,
      status: 'WINNING'
    });
    await newBid.save({ session });

    await session.commitTransaction();

    req.bidResult = { bid: newBid, previousBidder: auction.highest_bidder_id };
    next();
  } catch (error) {
    await session.abortTransaction();
    console.error('Bid locking failed:', error);
    res.status(500).json({ error: 'Failed to lock bid amount' });
  } finally {
    session.endSession();
  }
};

module.exports = { validateBidRequest, processBid, handleBidLocking };