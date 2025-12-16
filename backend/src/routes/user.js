const express = require("express");
const router = express.Router();
const User = require("../models/User");
const Auction = require("../models/Auction");
const Bid = require("../models/Bid");
const Notification = require("../models/Notification");
const { authMiddleware } = require("../middleware/auth");
const { weiToVnd, formatVnd } = require("../utils/conversion");

// Lấy danh sách tất cả users (cho mục đích testing/admin)
router.get("/", authMiddleware, async (req, res) => {
  try {
    const users = await User.find({}).select("-password_hash -encrypted_private_key");
    res.json(users);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Lấy thông tin hồ sơ của tôi (với ON-CHAIN balance)
router.get("/me", authMiddleware, async (req, res) => {
  try {
    // req.user được gán từ authMiddleware
    const user = await User.findById(req.user.id).select("-password_hash -encrypted_private_key");
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    // Convert user to plain object to allow modification
    const userObj = user.toObject();

    // ========== OVERRIDE WITH ON-CHAIN BALANCE ==========
    try {
      const { getOnChainBalance, isWalletContractAvailable } = require('../blockchain/wallet-contract');

      if (isWalletContractAvailable() && user.wallet_address) {
        console.log('📡 /me: Fetching on-chain balance for', user.wallet_address);
        const onChainBalance = await getOnChainBalance(user.wallet_address);

        // Override database balance with on-chain balance
        userObj.balance_eth = onChainBalance.total;
        userObj.locked_eth = onChainBalance.locked;
        userObj.balance_source = 'blockchain';
        console.log('✅ /me: Balance from blockchain:', onChainBalance.total, 'wei');
      } else {
        userObj.balance_source = 'database';
      }
    } catch (balanceError) {
      console.warn('⚠️ /me: On-chain balance failed:', balanceError.message);
      userObj.balance_source = 'database';
    }

    res.json(userObj);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
})

  ;
// Lấy thống kê của bản thân
router.get("/me/stats", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    // Count auctions created by this user
    const auctionsCount = await Auction.countDocuments({ seller_id: userId });

    // Count bids made by this user
    const bidsCount = await Bid.countDocuments({ user_id: userId });

    // Count wins (auctions where user is highest bidder and status is SETTLED or CONFIRMED)
    const winsCount = await Auction.countDocuments({
      highest_bidder_id: userId,
      status: { $in: ['SETTLED', 'CONFIRMED'] }
    });

    // Calculate success rate (wins / total participated auctions)
    const participatedAuctions = await Bid.aggregate([
      { $match: { user_id: user._id } },
      { $group: { _id: "$auction_id" } }
    ]);
    const totalParticipated = participatedAuctions.length;
    const successRate = totalParticipated > 0
      ? Math.round((winsCount / totalParticipated) * 100)
      : 0;

    res.json({
      auctions: auctionsCount,
      bids: bidsCount,
      wins: winsCount,
      successRate: successRate
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
// Lấy thông tin công khai của user theo ID
router.get("/:id", authMiddleware, async (req, res) => {
  try {
    const userId = req.params.id;
    const user = await User.findById(userId).select("-password_hash -encrypted_private_key -momo_phone");

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Lấy thống kê của user theo ID
router.get("/:id/stats", authMiddleware, async (req, res) => {
  try {
    const userId = req.params.id;
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    // Count auctions created by this user
    const auctionsCount = await Auction.countDocuments({ seller_id: userId });

    // Count bids made by this user
    const bidsCount = await Bid.countDocuments({ user_id: userId });

    // Count wins (auctions where user is highest bidder and status is SETTLED or CONFIRMED)
    const winsCount = await Auction.countDocuments({
      highest_bidder_id: userId,
      status: { $in: ['SETTLED', 'CONFIRMED'] }
    });

    // Calculate success rate (wins / total participated auctions)
    const participatedAuctions = await Bid.aggregate([
      { $match: { user_id: user._id } },
      { $group: { _id: "$auction_id" } }
    ]);
    const totalParticipated = participatedAuctions.length;
    const successRate = totalParticipated > 0
      ? Math.round((winsCount / totalParticipated) * 100)
      : 0;

    res.json({
      auctions: auctionsCount,
      bids: bidsCount,
      wins: winsCount,
      successRate: successRate
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


// Cập nhật thông tin hồ sơ của tôi
router.put("/me", authMiddleware, async (req, res) => {
  try {
    const { full_name, avatar, momo_phone, username, email, country, city, district, ward, address, bio } = req.body;
    const user = await User.findById(req.user.id);

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    // Check uniqueness for username if being updated
    if (username && username !== user.username) {
      const existingUser = await User.findOne({ username, _id: { $ne: user._id } });
      if (existingUser) {
        return res.status(400).json({ error: "Username already taken" });
      }
      user.username = username;
    }

    // Check uniqueness for email if being updated
    if (email && email !== user.email) {
      const existingUser = await User.findOne({ email, _id: { $ne: user._id } });
      if (existingUser) {
        return res.status(400).json({ error: "Email already taken" });
      }
      user.email = email;
    }

    // Update basic profile fields
    if (full_name !== undefined) user.full_name = full_name;
    if (avatar !== undefined) user.avatar = avatar;
    if (momo_phone !== undefined) user.momo_phone = momo_phone;

    // Update location & bio fields
    if (country !== undefined) user.country = country;
    if (city !== undefined) user.city = city;
    if (district !== undefined) user.district = district;
    if (ward !== undefined) user.ward = ward;
    if (address !== undefined) user.address = address;
    if (bio !== undefined) user.bio = bio;

    await user.save();

    const updatedUser = await User.findById(user._id).select("-password_hash -encrypted_private_key");
    res.json({
      success: true,
      message: "Profile updated successfully",
      user: updatedUser
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Lấy các phiên đấu giá TÔI TẠO RA
router.get("/me/auctions", authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    const auctions = await Auction.find({ seller_id: user._id })
      .populate('seller_id', 'username full_name')
      .populate('highest_bidder_id', 'username full_name')
      .populate('category_id', 'name')
      .sort({ createdAt: -1 }); // Mới nhất trước

    // Format with VND display
    const formattedAuctions = auctions.map(auction => ({
      ...auction.toObject(),
      start_price_vnd: weiToVnd(auction.start_price.toString()),
      step_price_vnd: weiToVnd(auction.step_price.toString()),
      current_price_vnd: weiToVnd(auction.current_price.toString()),
      formatted_start_price: formatVnd(weiToVnd(auction.start_price.toString())),
      formatted_step_price: formatVnd(weiToVnd(auction.step_price.toString())),
      formatted_current_price: formatVnd(weiToVnd(auction.current_price.toString())),
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
      images: auction.images, // IPFS URLs
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

// ========== API NOTIFICATIONS ==========

// Lấy danh sách thông báo
router.get("/me/notifications", authMiddleware, async (req, res) => {
  try {
    const notifications = await Notification.find({ user_id: req.user.id })
      .sort({ created_at: -1 })
      .limit(50); // Limit to last 50 notifications
    res.json(notifications);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Đánh dấu thông báo đã đọc
router.put("/me/notifications/read", authMiddleware, async (req, res) => {
  try {
    const { notification_ids } = req.body; // Array of IDs, or empty for all

    if (notification_ids && notification_ids.length > 0) {
      await Notification.updateMany(
        { _id: { $in: notification_ids }, user_id: req.user.id },
        { $set: { is_read: true } }
      );
    } else {
      // Mark all as read
      await Notification.updateMany(
        { user_id: req.user.id, is_read: false },
        { $set: { is_read: true } }
      );
    }

    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;