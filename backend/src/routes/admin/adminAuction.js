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
      const deployResult = await deployAuctionContract(auction);

      // ========== METADATA HASH PROTECTION ==========
      // 1. Calculate metadata hash
      const ethers = require('ethers');
      const metadataString = JSON.stringify({
        title: auction.title,
        description: auction.description,
        images: auction.images || []
      });
      const metadataHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(metadataString));

      console.log(`📝 Metadata hash calculated: ${metadataHash}`);

      // 2. Store metadata hash on-chain
      const fs = require('fs');
      const path = require('path');
      const abiPath = process.env.CONTRACT_ABI_PATH || './abi/Auction.json';
      const abiRaw = fs.readFileSync(path.resolve(abiPath), 'utf8');
      const abiParsed = JSON.parse(abiRaw);
      const abi = abiParsed.abi || abiParsed;

      const deployerWallet = walletFromPrivateKey(process.env.DEPLOYER_PRIVATE_KEY);
      const auctionContract = new ethers.Contract(deployResult.contract_address, abi, deployerWallet);

      console.log(`⛓️ Setting metadata hash on-chain for auction ${deployResult.blockchain_id}...`);
      const metadataTx = await auctionContract.setMetadataHash(deployResult.blockchain_id, metadataHash);
      const metadataReceipt = await metadataTx.wait();
      console.log(`✅ Metadata hash set on-chain in block ${metadataReceipt.blockNumber}`);
      // ========== END METADATA HASH PROTECTION ==========

      // deployResult now contains { contract_address, blockchain_id }
      await Auction.findByIdAndUpdate(auction._id, {
        status: AUCTION_STATUS.APPROVED,
        approved_by: requester._id,
        approved_at: new Date(),
        contract_address: deployResult.contract_address,
        blockchain_id: deployResult.blockchain_id,
        start_time: new Date(),
        // Metadata protection fields
        original_metadata: {
          title: auction.title,
          description: auction.description,
          images: auction.images || []
        },
        metadata_hash: metadataHash,
        metadata_hash_tx: metadataTx.hash
      });

      console.log(`✅ Auction ${auction._id} approved with blockchain_id: ${deployResult.blockchain_id}`);

      await Notification.create({ user_id: auction.seller_id._id, type: 'AUCTION_APPROVED', title: 'Your auction approved', message: `Auction ${auction.title} has been approved`, related_id: auction._id });

      return res.json({
        success: true,
        message: 'Auction approved and deployed',
        contract_address: deployResult.contract_address,
        blockchain_id: deployResult.blockchain_id,
        metadata_hash: metadataHash
      });
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
      await Notification.create({ user_id: auction.highest_bidder_id._id, type: 'WON_AUCTION', title: 'You won the auction', message: `You have won ${auction.title}`, related_id: auction._id });
    }
    await Notification.create({ user_id: auction.seller_id._id, type: 'AUCTION_SETTLED', title: 'Auction settled', message: `Your auction ${auction.title} has been settled.`, related_id: auction._id });

    return res.json({ success: true, message: 'Auction settled' });
  } catch (err) {
    console.error('admin settle error', err);
    return res.status(500).json({ error: 'Failed to settle auction' });
  }
});

// ========== BLOCKCHAIN AUDIT API ==========
// GET /api/admin/auctions/:id/audit - Audit bids, compare DB vs Blockchain
router.get('/:id/audit', authMiddleware, requireRole, [param('id').isMongoId()], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  try {
    const requester = req.requester;
    if (!['ADMIN', 'MANAGER'].includes(requester.role)) {
      return res.status(403).json({ error: 'Admin/Manager only' });
    }

    const auction = await Auction.findById(req.params.id);
    if (!auction) return res.status(404).json({ error: 'Auction not found' });

    // Check if auction has blockchain info
    if (!auction.blockchain_id || !auction.contract_address) {
      return res.json({
        auction_id: auction._id,
        title: auction.title,
        blockchain_id: null,
        message: '⚠️ Auction không có blockchain_id hoặc contract_address',
        audit_available: false
      });
    }

    // Load contract for this specific auction
    const fs = require('fs');
    const path = require('path');
    const ethers = require('ethers');

    const abiPath = process.env.CONTRACT_ABI_PATH || './abi/Auction.json';
    const abiRaw = fs.readFileSync(path.resolve(abiPath), 'utf8');
    const abiParsed = JSON.parse(abiRaw);
    const abi = abiParsed.abi || abiParsed;

    const auctionContract = new ethers.Contract(auction.contract_address, abi, provider);

    // Query BidRecorded events from blockchain
    const filter = auctionContract.filters.BidRecorded(auction.blockchain_id);
    const events = await auctionContract.queryFilter(filter);

    console.log(`📊 Audit: Found ${events.length} BidRecorded events on-chain for auction ${auction.blockchain_id}`);

    // Get all bids from MongoDB
    const dbBids = await Bid.find({ auction_id: auction._id })
      .populate('user_id', 'wallet_address full_name username')
      .sort({ timestamp: 1 });

    // Build audit report
    const auditResults = [];
    let tamperedCount = 0;
    let verifiedCount = 0;
    let notRecordedCount = 0;

    for (const dbBid of dbBids) {
      const result = {
        bid_id: dbBid._id,
        bidder: dbBid.user_id?.full_name || dbBid.user_id?.username,
        bidder_address: dbBid.user_id?.wallet_address,
        db_amount_wei: dbBid.amount_wei,
        db_amount_vnd: dbBid.amount_vnd,
        timestamp: dbBid.timestamp,
        on_chain_tx_hash: dbBid.on_chain_tx_hash,
        on_chain_block: dbBid.on_chain_block,
        on_chain_bid_hash: dbBid.on_chain_bid_hash,
        status: 'UNKNOWN'
      };

      if (!dbBid.on_chain_bid_hash) {
        result.status = 'NOT_RECORDED';
        result.message = '⚠️ Bid không được ghi on-chain';
        notRecordedCount++;
      } else {
        // Find matching event on blockchain
        const matchingEvent = events.find(e =>
          e.args.bidHash.toLowerCase() === dbBid.on_chain_bid_hash.toLowerCase()
        );

        if (matchingEvent) {
          // Compare amounts
          const chainAmount = matchingEvent.args.amount.toString();
          if (chainAmount === dbBid.amount_wei) {
            result.status = 'VERIFIED';
            result.message = '✅ Dữ liệu KHỚP với blockchain';
            result.chain_amount_wei = chainAmount;
            verifiedCount++;
          } else {
            result.status = 'TAMPERED';
            result.message = '🚨 DỮ LIỆU ĐÃ BỊ THAY ĐỔI!';
            result.chain_amount_wei = chainAmount;
            result.discrepancy = {
              db_value: dbBid.amount_wei,
              chain_value: chainAmount,
              difference: (BigInt(dbBid.amount_wei) - BigInt(chainAmount)).toString()
            };
            tamperedCount++;
          }
        } else {
          result.status = 'HASH_NOT_FOUND';
          result.message = '❓ Hash không tìm thấy trên blockchain';
          notRecordedCount++;
        }
      }

      auditResults.push(result);
    }

    // Summary
    const summary = {
      total_bids_db: dbBids.length,
      total_bids_chain: events.length,
      verified: verifiedCount,
      tampered: tamperedCount,
      not_recorded: notRecordedCount,
      integrity_score: dbBids.length > 0
        ? Math.round((verifiedCount / dbBids.length) * 100)
        : 100
    };

    res.json({
      auction_id: auction._id,
      title: auction.title,
      blockchain_id: auction.blockchain_id,
      contract_address: auction.contract_address,
      audit_timestamp: new Date().toISOString(),
      summary,
      bids: auditResults,
      overall_status: tamperedCount > 0
        ? '🚨 PHÁT HIỆN GIAN LẬN'
        : (notRecordedCount > 0
          ? '⚠️ Một số bid chưa được ghi on-chain'
          : '✅ TẤT CẢ DỮ LIỆU HỢP LỆ')
    });

  } catch (err) {
    console.error('Audit error:', err);
    return res.status(500).json({ error: 'Audit failed', details: err.message });
  }
});

// ========== RESTORE BID FROM BLOCKCHAIN ==========
// POST /api/admin/auctions/restore-bid/:bidId - Restore bid data from blockchain
router.post('/restore-bid/:bidId', authMiddleware, requireRole, [param('bidId').isMongoId()], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  try {
    const requester = req.requester;
    if (requester.role !== 'ADMIN') {
      return res.status(403).json({ error: 'Admin only - Restore requires highest privilege' });
    }

    const bid = await Bid.findById(req.params.bidId).populate('auction_id');
    if (!bid) return res.status(404).json({ error: 'Bid not found' });

    const auction = bid.auction_id;
    if (!auction.blockchain_id || !auction.contract_address) {
      return res.status(400).json({ error: 'Auction không có blockchain info' });
    }

    if (!bid.on_chain_bid_hash) {
      return res.status(400).json({ error: 'Bid không có on_chain_bid_hash - cannot restore' });
    }

    // Load contract
    const fs = require('fs');
    const path = require('path');
    const ethers = require('ethers');

    const abiPath = process.env.CONTRACT_ABI_PATH || './abi/Auction.json';
    const abiRaw = fs.readFileSync(path.resolve(abiPath), 'utf8');
    const abiParsed = JSON.parse(abiRaw);
    const abi = abiParsed.abi || abiParsed;

    const auctionContract = new ethers.Contract(auction.contract_address, abi, provider);

    // Query events
    const filter = auctionContract.filters.BidRecorded(auction.blockchain_id);
    const events = await auctionContract.queryFilter(filter);

    // Find matching event
    const matchingEvent = events.find(e =>
      e.args.bidHash.toLowerCase() === bid.on_chain_bid_hash.toLowerCase()
    );

    if (!matchingEvent) {
      return res.status(404).json({ error: 'Không tìm thấy dữ liệu on-chain cho bid này' });
    }

    // Get original data from blockchain
    const originalAmountWei = matchingEvent.args.amount.toString();
    const { weiToVnd } = require('../../utils/conversion');
    const originalAmountVnd = weiToVnd(originalAmountWei);

    // Store old values for logging
    const oldValues = {
      amount_wei: bid.amount_wei,
      amount_vnd: bid.amount_vnd
    };

    // Restore
    await Bid.findByIdAndUpdate(bid._id, {
      amount_wei: originalAmountWei,
      amount_vnd: originalAmountVnd,
      restored_from_chain: true,
      restored_at: new Date(),
      restored_by: requester._id
    });

    console.log(`🔄 Bid ${bid._id} restored from blockchain by ${requester.username}`);
    console.log(`   Old: ${oldValues.amount_vnd} VND → New: ${originalAmountVnd} VND`);

    res.json({
      success: true,
      message: '✅ Bid đã được khôi phục từ blockchain',
      bid_id: bid._id,
      old_values: oldValues,
      restored_values: {
        amount_wei: originalAmountWei,
        amount_vnd: originalAmountVnd
      },
      blockchain_proof: {
        tx_hash: bid.on_chain_tx_hash,
        block_number: matchingEvent.blockNumber,
        event_index: matchingEvent.logIndex
      },
      restored_by: requester.username,
      restored_at: new Date().toISOString()
    });

  } catch (err) {
    console.error('Restore error:', err);
    return res.status(500).json({ error: 'Restore failed', details: err.message });
  }
});

module.exports = router;
