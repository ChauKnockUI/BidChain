// routes/user.js
const express = require("express");
const router = express.Router();
const User = require("../models/User");
const Auction = require("../models/Auction");
const Bid = require("../models/Bid");
const { authMiddleware } = require("../middleware/auth");
const { weiToVnd, formatVnd } = require("../utils/conversion");

// Lấy thông tin hồ sơ của tôi
router.get("/me", authMiddleware, async (req, res) => {
  try {
    // req.user được gán từ authMiddleware
    const user = await User.findById(req.user.id).select("-password_hash -encrypted_private_key");
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
    const auctions = await Auction.find({ seller_id: user._id })
                                  .populate('highest_bidder_id', 'username')
                                  .sort({ created_at: -1 }); // Mới nhất trước

    // Format with VND display
    const formattedAuctions = auctions.map(auction => ({
      _id: auction._id,
      title: auction.title,
      status: auction.status,
      start_price_vnd: weiToVnd(auction.start_price.toString()),
      current_price_vnd: weiToVnd(auction.current_price.toString()),
      formatted_start_price: formatVnd(weiToVnd(auction.start_price.toString())),
      formatted_current_price: formatVnd(weiToVnd(auction.current_price.toString())),
      end_time: auction.end_time,
      highest_bidder: auction.highest_bidder_id?.username || null
    }));

    res.json(formattedAuctions);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Lấy các phiên đấu giá TÔI ĐANG BID (hoặc đã thắng)
router.get("/me/bids", authMiddleware, async (req, res) => {
    try {
        const user = await User.findById(req.user.id);

        // Get all bids by this user
        const userBids = await Bid.find({ user_id: user._id })
                                  .populate('auction_id')
                                  .sort({ created_at: -1 });

        // Group by auction and get latest bid per auction
        const auctionMap = new Map();
        userBids.forEach(bid => {
          const auctionId = bid.auction_id._id.toString();
          if (!auctionMap.has(auctionId) ||
              bid.created_at > auctionMap.get(auctionId).bid.created_at) {
            auctionMap.set(auctionId, {
              auction: bid.auction_id,
              bid: bid
            });
          }
        });

        // Format response
        const result = Array.from(auctionMap.values()).map(({ auction, bid }) => ({
          auction_id: auction._id,
          title: auction.title,
          status: auction.status,
          my_bid_amount: weiToVnd(bid.amount_wei.toString()),
          formatted_my_bid: formatVnd(weiToVnd(bid.amount_wei.toString())),
          current_price: weiToVnd(auction.current_price.toString()),
          formatted_current_price: formatVnd(weiToVnd(auction.current_price.toString())),
          bid_status: bid.status,
          bid_time: bid.created_at,
          end_time: auction.end_time,
          is_winner: auction.highest_bidder_id?.toString() === user._id.toString() && auction.status === 'SETTLED'
        }));

        res.json(result);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;