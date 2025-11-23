// routes/user.js
const express = require("express");
const router = express.Router();
const User = require("../models/User");
const OffchainAuction = require("../models/OffchainAuction");
const { authMiddleware } = require("../middleware/auth");

// Lấy thông tin hồ sơ của tôi
router.get("/me", authMiddleware, async (req, res) => {
  try {
    // req.user được gán từ authMiddleware
    const user = await User.findById(req.user.id).select("-passwordHash -encryptedPrivateKey");
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Lấy các phiên đấu giá TÔI TẠO
router.get("/me/auctions", authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    const auctions = await OffchainAuction.find({ seller: user.ethAddress })
                                        .sort({ createdAt: -1 }); // Mới nhất trước
    res.json(auctions);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Lấy các phiên đấu giá TÔI ĐANG BID (hoặc đã thắng)
router.get("/me/bids", authMiddleware, async (req, res) => {
    try {
        const user = await User.findById(req.user.id);
        const auctions = await OffchainAuction.find({ 
            $or: [
                { highestBidder: user.ethAddress }, // Tôi đang bid cao nhất
                { winner: user.ethAddress }         // Hoặc tôi đã thắng
            ]
        }).sort({ endTime: -1 });
        res.json(auctions);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;