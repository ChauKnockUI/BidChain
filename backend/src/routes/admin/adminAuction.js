const express = require('express');
const router = express.Router();
const { param, query, body, validationResult } = require('express-validator');
const { authMiddleware } = require('../../middleware/auth');
const User = require('../../models/User');
const Auction = require('../../models/Auction');
const Bid = require('../../models/Bid');
const Notification = require('../../models/Notification');
const { deployAuctionContract } = require('../../blockchain/deploy');
const { provider, walletFromPrivateKey, contract } = require('../../blockchain/contract');
const { decrypt } = require('../../utils/crypto');
const { AUCTION_STATUS } = require('../../config/constants');

// Role helper
async function requireRole(req, res, next) {
  try {
    const user = await User.findById(req.user.id);
    if (!user) return res.status(404).json({ error: 'User not found' });
    req.requester = user;
    return next();
  } catch (err) {
    console.error('role check error', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

// GET /api/admin/auctions - list auctions with filter
router.get('/', authMiddleware, requireRole, async (req, res) => {
  try {
    const requester = req.requester;
    if (!['ADMIN', 'MANAGER'].includes(requester.role)) {
      return res.status(403).json({ error: 'Admin/Manager only' });
    }

    const { status, page = 1, limit = 20 } = req.query;
    const queryFilter = status ? { status } : {};
    const skip = (page - 1) * limit;

    const auctions = await Auction.find(queryFilter)
      .populate('seller_id', 'username full_name email')
      .populate('approved_by', 'username full_name')
      .populate('highest_bidder_id', 'username full_name')
      .sort({ created_at: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    const total = await Auction.countDocuments(queryFilter);

    const formatted = auctions.map(a => ({
      id: a._id,
      title: a.title,
      status: a.status,
      seller: { id: a.seller_id?._id, username: a.seller_id?.username, full_name: a.seller_id?.full_name },
      highest_bidder: a.highest_bidder_id ? { id: a.highest_bidder_id._id, username: a.highest_bidder_id.username } : null,
      start_price_vnd: require('../../utils/conversion').weiToVnd(a.start_price.toString()),
      current_price_vnd: require('../../utils/conversion').weiToVnd(a.current_price.toString()),
      start_time: a.start_time,
      end_time: a.end_time,
      created_at: a.created_at,
      images: a.images || []
    }));

    return res.json({ total, page: parseInt(page), limit: parseInt(limit), auctions: formatted });
  } catch (err) {
    console.error('admin list auctions error', err);
    return res.status(500).json({ error: 'Failed to list auctions' });
  }
});

// GET /api/admin/auctions/:id - details
router.get('/:id', authMiddleware, requireRole, [param('id').isMongoId()], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });
  try {
    const requester = req.requester;
    if (!['ADMIN', 'MANAGER'].includes(requester.role)) {
      return res.status(403).json({ error: 'Admin/Manager only' });
    }

    const auction = await Auction.findById(req.params.id)
      .populate('seller_id', 'username full_name email')
      .populate('approved_by', 'username full_name')
      .populate('highest_bidder_id', 'username full_name');
    if (!auction) return res.status(404).json({ error: 'Auction not found' });

    const bids = await Bid.find({ auction_id: auction._id }).populate('user_id', 'username full_name').sort({ created_at: -1 });

    return res.json({ auction, bids });
  } catch (err) {
    console.error('admin auction detail error', err);
    return res.status(500).json({ error: 'Failed to get auction details' });
  }
});

// POST /api/admin/auctions/:id/approve - Manager/Admin
router.post('/:id/approve', authMiddleware, requireRole, [param('id').isMongoId()], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });
  try {
    const requester = req.requester;
    if (!['ADMIN', 'MANAGER'].includes(requester.role)) {
      return res.status(403).json({ error: 'Admin/Manager only' });
    }

    const auction = await Auction.findById(req.params.id).populate('seller_id');
    if (!auction) return res.status(404).json({ error: 'Auction not found' });
    if (auction.status !== 'PENDING_APPROVAL') return res.status(400).json({ error: 'Auction not pending approval' });

    // deploy contract
    try {
      const contractAddress = await deployAuctionContract(auction);
      await Auction.findByIdAndUpdate(auction._id, {
        status: AUCTION_STATUS.APPROVED,
        approved_by: requester._id,
        approved_at: new Date(),
        contract_address: contractAddress,
        start_time: new Date()
      });

      await Notification.create({ user_id: auction.seller_id._id, type: 'AUCTION_APPROVED', title: 'Your auction approved', message: `Auction ${auction.title} has been approved`, related_id: auction._id });

      return res.json({ success: true, message: 'Auction approved and deployed', contract_address: contractAddress });
    } catch (err) {
      console.error('deploy fail in admin approve', err);
      return res.status(500).json({ error: 'Deploy failed', details: err.message });
    }
  } catch (err) {
    console.error('admin approve error', err);
    return res.status(500).json({ error: 'Failed to approve' });
  }
});

// POST /api/admin/auctions/:id/reject - Manager/Admin
router.post('/:id/reject', authMiddleware, requireRole, [param('id').isMongoId(), body('reason').isString().notEmpty()], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });
  try {
    const requester = req.requester;
    if (!['ADMIN', 'MANAGER'].includes(requester.role)) {
      return res.status(403).json({ error: 'Admin/Manager only' });
    }
    const auction = await Auction.findById(req.params.id).populate('seller_id');
    if (!auction) return res.status(404).json({ error: 'Auction not found' });
    if (auction.status !== 'PENDING_APPROVAL') return res.status(400).json({ error: 'Auction not pending approval' });

    await Auction.findByIdAndUpdate(auction._id, { status: AUCTION_STATUS.REJECTED, approved_by: requester._id, approved_at: new Date(), rejection_reason: req.body.reason });
    await Notification.create({ user_id: auction.seller_id._id, type: 'AUCTION_REJECTED', title: 'Auction rejected', message: `Your auction ${auction.title} was rejected: ${req.body.reason}`, related_id: auction._id });
    return res.json({ success: true, message: 'Auction rejected' });
  } catch (err) {
    console.error('admin reject error', err);
    return res.status(500).json({ error: 'Failed to reject auction' });
  }
});

// POST /api/admin/auctions/:id/deploy - Admin only (deploy contract separately)
router.post('/:id/deploy', authMiddleware, requireRole, [param('id').isMongoId()], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });
  try {
    const requester = req.requester;
    if (requester.role !== 'ADMIN') return res.status(403).json({ error: 'Admin only' });
    const auction = await Auction.findById(req.params.id);
    if (!auction) return res.status(404).json({ error: 'Auction not found' });
    // Deploy and update contract address
    try {
      const contractAddress = await deployAuctionContract(auction);
      await Auction.findByIdAndUpdate(auction._id, { contract_address: contractAddress, deploy_tx_hash: null, status: AUCTION_STATUS.DEPLOYING });
      return res.json({ success: true, contract_address });
    } catch (err) {
      console.error('deploy error', err);
      return res.status(500).json({ error: 'Deploy failed', details: err.message });
    }
  } catch (err) {
    console.error('admin deploy error', err);
    return res.status(500).json({ error: 'Failed to deploy' });
  }
});

// POST /api/admin/auctions/:id/start - Admin: set start_time and status to ACTIVE (and attempt on-chain start if available)
router.post('/:id/start', authMiddleware, requireRole, [param('id').isMongoId()], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });
  try {
    const requester = req.requester;
    if (requester.role !== 'ADMIN') return res.status(403).json({ error: 'Admin only' });
    const auction = await Auction.findById(req.params.id).populate('seller_id');
    if (!auction) return res.status(404).json({ error: 'Auction not found' });

    // Update start_time and status
    await Auction.findByIdAndUpdate(auction._id, { start_time: new Date(), status: AUCTION_STATUS.ACTIVE });

    // Try calling on-chain start - if contract exposes function startAuction
    try {
      if (auction.contract_address) {
        // attempt to call start if available using admin wallet
        const adminWallet = walletFromPrivateKey(process.env.ADMIN_PRIVATE_KEY);
        const tx = await contract.connect(adminWallet).startAuction(auction._id);
        await tx.wait();
      }
    } catch (chainErr) {
      // Not fatal: continue but log
      console.warn('on-chain start auction call failed (may not exist):', chainErr.message);
    }

    await Notification.create({ user_id: auction.seller_id._id, type: 'AUCTION_STARTED', title: 'Auction started', message: `Auction ${auction.title} has been started by admin`, related_id: auction._id });
    return res.json({ success: true, message: 'Auction started' });
  } catch (err) {
    console.error('admin start error', err);
    return res.status(500).json({ error: 'Failed to start auction' });
  }
});

// POST /api/admin/auctions/:id/end - Admin: trigger on-chain endAuction using ADMIN private key
router.post('/:id/end', authMiddleware, requireRole, [param('id').isMongoId()], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });
  try {
    const requester = req.requester;
    if (requester.role !== 'ADMIN') return res.status(403).json({ error: 'Admin only' });
    const auction = await Auction.findById(req.params.id);
    if (!auction) return res.status(404).json({ error: 'Auction not found' });

    try {
      const adminWallet = walletFromPrivateKey(process.env.ADMIN_PRIVATE_KEY);
      const tx = await contract.connect(adminWallet).endAuction(BigInt(auction._id));
      const receipt = await tx.wait();
      // Mark auction as ENDED
      await Auction.findByIdAndUpdate(auction._id, { status: AUCTION_STATUS.ENDED });
      return res.json({ success: true, message: 'Auction ended on-chain', tx_hash: receipt.transactionHash });
    } catch (chainErr) {
      console.error('endAuction chain error', chainErr);
      return res.status(500).json({ error: 'Failed to end on-chain', details: chainErr.message });
    }

  } catch (err) {
    console.error('admin end error', err);
    return res.status(500).json({ error: 'Failed to end auction' });
  }
});

// POST /api/admin/auctions/:id/settle - Admin: finalise auction (mark SETTLED, create notifications) - logic may vary by project
router.post('/:id/settle', authMiddleware, requireRole, [param('id').isMongoId()], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });
  try {
    const requester = req.requester;
    if (requester.role !== 'ADMIN') return res.status(403).json({ error: 'Admin only' });
    const auction = await Auction.findById(req.params.id).populate('highest_bidder_id').populate('seller_id');
    if (!auction) return res.status(404).json({ error: 'Auction not found' });

    // Update status
    await Auction.findByIdAndUpdate(auction._id, { status: AUCTION_STATUS.SETTLED });

    // Notify winner and seller
    if (auction.highest_bidder_id) {
      await Notification.create({ user_id: auction.highest_bidder_id._id, type: 'WON_AUCTION', title: 'You won the auction', message: `You have won ${auction.title}` , related_id: auction._id });
    }
    await Notification.create({ user_id: auction.seller_id._id, type: 'AUCTION_SETTLED', title: 'Auction settled', message: `Your auction ${auction.title} has been settled.`, related_id: auction._id });

    return res.json({ success: true, message: 'Auction settled' });
  } catch (err) {
    console.error('admin settle error', err);
    return res.status(500).json({ error: 'Failed to settle auction' });
  }
});

module.exports = router;
