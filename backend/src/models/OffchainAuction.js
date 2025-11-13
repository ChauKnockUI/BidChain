const mongoose = require('mongoose');

const OffchainAuctionSchema = new mongoose.Schema({
  auctionId: Number,
  seller: String,
  startingPrice: String,
  highestBid: String,
  highestBidder: String,
  endTime: Number,
  ended: Boolean,
  metadataUrl: String,
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('OffchainAuction', OffchainAuctionSchema);