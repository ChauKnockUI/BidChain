// models/OffchainAuction.js
const mongoose = require("mongoose");

const OffchainAuctionSchema = new mongoose.Schema(
  {
    // ID từ Smart Contract
    auctionId: {
      type: Number,
      required: true,
      unique: true,
      index: true,
    },
    // Dữ liệu tĩnh (lấy từ event AuctionCreated)
    seller: { type: String, required: true, lowercase: true, index: true },
    startingPrice: { type: String, required: true }, // Lưu bằng Wei
    endTime: { type: Date, required: true },
    metadataUrl: { type: String, default: "" },

    // Dữ liệu động (cập nhật bởi event NewBid, AuctionEnded)
    highestBid: { type: String, required: true }, // Lưu bằng Wei
    highestBidder: { type: String, required: true, lowercase: true, index: true },
    ended: { type: Boolean, default: false, index: true },
    winner: { type: String, lowercase: true, default: null },
  },
  { timestamps: true } // Tự động thêm createdAt, updatedAt
);

module.exports = mongoose.model("OffchainAuction", OffchainAuctionSchema);