const mongoose = require("mongoose");

const BidHistorySchema = new mongoose.Schema({
  auctionId: Number,
  bidder: String,
  amount: String,
  timestamp: Number
}, { timestamps: true });

module.exports = mongoose.model("BidHistory", BidHistorySchema);
