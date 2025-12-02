const express = require('express');
const router = express.Router();
const { query, validationResult } = require('express-validator');
const { authMiddleware } = require('../../middleware/auth');
const User = require('../../models/User');
const Auction = require('../../models/Auction');
const Bid = require('../../models/Bid');
const Transaction = require('../../models/Transaction');
const { weiToVnd, weiToEth } = require('../../utils/conversion');
const { AUCTION_STATUS } = require('../../config/constants');

// Role helper: require manager or admin
async function requireManagerOrAdmin(req, res, next) {
  try {
    const user = await User.findById(req.user.id);
    if (!user) return res.status(404).json({ error: 'User not found' });
    if (!['ADMIN', 'MANAGER'].includes(user.role)) return res.status(403).json({ error: 'Admin/Manager only' });
    req.requester = user;
    return next();
  } catch (err) {
    console.error('role check error', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

// GET /api/
router.get('/stats', authMiddleware, requireManagerOrAdmin, async (req, res) => {
  try {
    // Total volume VND/ETH (sum of all COMPLETED transactions)
    const txAgg = await Transaction.aggregate([
      { $match: { status: 'COMPLETED' } },
      {
        $group: {
          _id: null,
          total_vnd: { $sum: '$amount_vnd' },
          total_eth: { $sum: '$amount_eth' }
        }
      }
    ]);

    const total_vnd = txAgg?.[0]?.total_vnd ? parseFloat(txAgg[0].total_vnd.toString()) : 0;
    const total_eth = txAgg?.[0]?.total_eth ? parseFloat(txAgg[0].total_eth.toString()) : 0;

    // Active auctions count
    const activeAuctions = await Auction.countDocuments({ status: AUCTION_STATUS.ACTIVE });

    // Number of unique bidders
    const bidderIds = await Bid.distinct('user_id');
    const numBidders = bidderIds.length || 0;

    // Average increase: average percent increase from start_price to current_price for settled/ended/active auctions
    const auctions = await Auction.find({ status: { $in: [AUCTION_STATUS.ACTIVE, AUCTION_STATUS.ENDED, AUCTION_STATUS.SETTLED] } }).select('start_price current_price');
    let avgIncrease = 0;
    if (auctions.length > 0) {
      const increases = auctions.map(a => {
        const startEth = weiToEth(a.start_price ? a.start_price.toString() : '0');
        const currentEth = weiToEth(a.current_price ? a.current_price.toString() : '0');
        if (!startEth || startEth === 0) return 0;
        const inc = ((currentEth - startEth) / startEth) * 100;
        return isFinite(inc) ? inc : 0;
      });
      const sum = increases.reduce((s, v) => s + v, 0);
      avgIncrease = sum / auctions.length;
    }

    return res.json({
      total_volume_vnd: total_vnd,
      total_volume_eth: total_eth,
      active_auctions: activeAuctions,
      num_bidders: numBidders,
      average_increase_percent: Number(avgIncrease.toFixed(2))
    });
  } catch (err) {
    console.error('dashboard stats error', err);
    res.status(500).json({ error: 'Failed to fetch stats' });
  }
});

// GET /api/admin/dashboard/volume-by-month?year=2025
router.get('/volume-by-month', authMiddleware, requireManagerOrAdmin, [query('year').optional().isInt()], async (req, res) => {
  try {
    const year = parseInt(req.query.year || new Date().getFullYear());
    // Match completed transactions in given year (use created_at)
    const start = new Date(year, 0, 1);
    const end = new Date(year + 1, 0, 1);

    const agg = await Transaction.aggregate([
      { $match: { status: 'COMPLETED', created_at: { $gte: start, $lt: end } } },
      {
        $group: {
          _id: { $month: '$created_at' },
          total_vnd: { $sum: { $ifNull: ['$amount_vnd', 0] } },
          total_eth: { $sum: { $ifNull: ['$amount_eth', 0] } }
        }
      }
    ]);

    // Build 12 months output
    const months = Array.from({ length: 12 }, (_, i) => ({ month: i + 1, total_vnd: 0, total_eth: 0 }));
    for (const row of agg) {
      const idx = row._id - 1;
      months[idx].total_vnd = row.total_vnd ? parseFloat(row.total_vnd.toString()) : 0;
      months[idx].total_eth = row.total_eth ? parseFloat(row.total_eth.toString()) : 0;
    }

    return res.json({ year, months });
  } catch (err) {
    console.error('volume by month error', err);
    return res.status(500).json({ error: 'Failed to fetch volume by month' });
  }
});

// GET /api/admin/dashboard/status-counts
router.get('/status-counts', authMiddleware, requireManagerOrAdmin, async (req, res) => {
  try {
    const agg = await Auction.aggregate([
      { $group: { _id: '$status', count: { $sum: 1 } } }
    ]);
    const result = {};
    for (const row of agg) result[row._id] = row.count;
    return res.json(result);
  } catch (err) {
    console.error('status counts error', err);
    return res.status(500).json({ error: 'Failed to fetch status counts' });
  }
});

// GET /api/admin/dashboard/top-bidders?limit=5
router.get('/top-bidders', authMiddleware, requireManagerOrAdmin, [query('limit').optional().isInt()], async (req, res) => {
  try {
    const limit = parseInt(req.query.limit || 5);
    const agg = await Bid.aggregate([
      {
        $group: {
          _id: '$user_id',
          totalWei: { $sum: '$amount_wei' }
        }
      },
      { $sort: { totalWei: -1 } },
      { $limit: limit }
    ]);

    // Attach user info and convert to VND/ETH
    const top = [];
    for (const row of agg) {
      const user = await User.findById(row._id).select('username full_name email');
      const totalWeiStr = row.totalWei ? row.totalWei.toString() : '0';
      top.push({
        user_id: row._id,
        username: user?.username,
        full_name: user?.full_name,
        email: user?.email,
        total_wei: totalWeiStr,
        total_eth: Number(weiToEth(totalWeiStr)),
        total_vnd: Number(weiToVnd(totalWeiStr))
      });
    }
    return res.json({ top_bidders: top });
  } catch (err) {
    console.error('top bidders error', err);
    return res.status(500).json({ error: 'Failed to fetch top bidders' });
  }
});

module.exports = router;
