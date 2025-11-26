const express = require("express");
const router = express.Router();
const User = require("../models/User");
const Auction = require("../models/Auction");
const Bid = require("../models/Bid");
const Transaction = require("../models/Transaction");
const Notification = require("../models/Notification");
const { ethers } = require("ethers");
const { decrypt } = require("../utils/crypto");
const { authMiddleware } = require("../middleware/auth");
const { provider, contract } = require("../blockchain/contract");
const { body, param, validationResult } = require("express-validator");
const { validateBidRequest, processBid, handleBidLocking } = require("../middleware/bid");
const { ethToVnd, weiToVnd, formatVnd, vndToWei, weiToEth, formatEth } = require("../utils/conversion");
const { EXCHANGE_RATE, AUCTION_STATUS, TRANSACTION_TYPES } = require("../config/constants");
const { deployAuctionContract } = require("../blockchain/deploy");

require("dotenv").config();

// ========== API LẤY SỐ DƯ ==========
// routes/auction.js hoặc wallet route
router.get("/wallet/balance", authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) return res.status(404).json({ error: "User not found" });

    // ĐẢM BẢO balance_eth và locked_eth là STRING wei
    const balanceWei = user.balance_eth.toString(); // luôn là string
    const lockedWei = user.locked_eth.toString();

    const balanceEth = weiToEth(balanceWei);
    const lockedEth = weiToEth(lockedWei);
    const availableEth = balanceEth - lockedEth;

    const balanceVnd = weiToVnd(balanceWei);
    const lockedVnd = weiToVnd(lockedWei);
    const availableVnd = weiToVnd(ethers.utils.parseUnits(availableEth.toFixed(18), 18).toString());

    res.json({
      wallet_address: user.wallet_address,
      balance_eth: balanceEth.toFixed(6),
      locked_eth: lockedEth.toFixed(6),
      available_eth: availableEth < 0 ? 0 : availableEth.toFixed(6),

      balance_vnd: balanceVnd,
      locked_vnd: lockedVnd,
      available_vnd: availableVnd,

      formatted_balance: formatVnd(balanceVnd),
      formatted_locked: formatVnd(lockedVnd),
      formatted_available: formatVnd(availableVnd),
      formatted_balance_eth: formatEth(balanceWei),
      formatted_available_eth: formatEth(ethers.utils.parseUnits(availableEth.toFixed(18), 18).toString())
    });
  } catch (error) {
    console.error('Error getting balance:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});
// ========== API TẠO PHIÊN ĐẤU GIÁ (REQUEST APPROVAL) ==========
router.post("/create", authMiddleware, [
    body("title").isString().notEmpty().withMessage("Title is required"),
    body("description").isString().notEmpty().withMessage("Description is required"),
    body("start_price").isFloat({ min: 10000 }).withMessage("Start price must be at least 10,000 VND"),
    body("step_price").isFloat({ min: 1000 }).withMessage("Step price must be at least 1,000 VND"),
    body("end_time").isISO8601().withMessage("Valid end time required"),
    body("images").isArray().optional(),
    body("category_id").isMongoId().withMessage("Valid category required")
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    try {
        const {
            title,
            description,
            start_price, // VND
            step_price,  // VND
            end_time,
            images = [],
            category_id
        } = req.body;

        const user = await User.findById(req.user.id);
        if (!user) return res.status(404).json({ error: "User not found" });

        // Check if user has USER role
        if (user.role !== 'USER') {
            return res.status(403).json({ error: "Only sellers can create auctions" });
        }

        // Convert VND to Wei for storage
        const startPriceWei = vndToWei(start_price);
        const stepPriceWei = vndToWei(step_price);

        // Validate end_time is in future
        const endTime = new Date(end_time);
        const now = new Date();
        if (endTime <= now) {
            return res.status(400).json({ error: "End time must be in the future" });
        }

        // Create auction in PENDING_APPROVAL status
        const auction = new Auction({
            seller_id: user._id,
            title: title.trim(),
            description: description.trim(),
            images,
            category_id,
            status: AUCTION_STATUS.PENDING_APPROVAL,
            start_price: startPriceWei.toString(), // Store as string for Decimal128
            step_price: stepPriceWei.toString(),
            current_price: startPriceWei.toString(),
            end_time: endTime,
            start_time: null, // Will be set when approved
            approved_by: null,
            approved_at: null,
            contract_address: null,
            deploy_tx_hash: null
        });

        await auction.save();

        // Create notification for admin/managers
        const Notification = require('../models/Notification');
        const managers = await User.find({ role: { $in: ['ADMIN', 'MANAGER'] } });

        for (const manager of managers) {
            await Notification.create({
                user_id: manager._id,
                type: 'AUCTION_PENDING_APPROVAL',
                title: 'Yêu cầu duyệt phiên đấu giá mới',
                message: `${user.full_name} đã tạo yêu cầu duyệt phiên đấu giá: ${title}`,
                related_id: auction._id
            });
        }

        res.status(201).json({
            message: "Auction request created successfully",
            auction: {
                id: auction._id,
                title: auction.title,
                status: auction.status,
                start_price_vnd: start_price,
                step_price_vnd: step_price,
                formatted_start_price: formatVnd(start_price),
                formatted_step_price: formatVnd(step_price),
                end_time: auction.end_time
            }
        });

    } catch (error) {
        console.error('Create auction error:', error);
        if (error.name === 'ValidationError') {
            const errors = Object.values(error.errors).map(e => e.message);
            return res.status(400).json({ error: "Validation failed", details: errors });
        }
        res.status(500).json({ error: "Failed to create auction request" });
    }
});

// ========== API BID ==========
router.post(
  "/bid",
  authMiddleware,
  validateBidRequest,
  processBid,
  handleBidLocking,
  async (req, res) => {
    try {
      const io = req.app.get('io'); // Get socket.io instance
      const { bidResult, bidData } = req;

      // Emit real-time update to all clients in auction room
      const roomName = `auction_${bidData.auction._id}`;
      io.to(roomName).emit('new_bid', {
        auction_id: bidData.auction._id,
        bidder_id: bidData.user._id,
        bidder_name: bidData.user.full_name,
        amount_wei: bidData.amountWei,
        amount_vnd: bidData.amountVnd,
        formatted_amount: formatVnd(bidData.amountVnd),
        timestamp: new Date()
      });

      // Notify previous bidder if any
      if (bidResult.previousBidder) {
        // Create notification for outbid user
        const notification = new Notification({
          user_id: bidResult.previousBidder,
          type: 'OUTBID',
          title: 'Bạn đã bị vượt giá',
          message: `Giá của bạn đã bị vượt mặt trong phiên đấu giá. Số dư đã được hoàn lại.`,
          related_id: bidData.auction._id
        });
        await notification.save();

        // Emit notification to previous bidder
        io.to(`user_${bidResult.previousBidder}`).emit('notification', {
          type: 'OUTBID',
          title: notification.title,
          message: notification.message,
          auction_id: bidData.auction._id
        });
      }

      return res.json({
        success: true,
        message: 'Bid placed successfully',
        bid_id: bidResult.bid._id,
        amount_vnd: bidData.amountVnd,
        formatted_amount: formatVnd(bidData.amountVnd),
        current_price_vnd: bidData.amountVnd,
        formatted_current_price: formatVnd(bidData.amountVnd)
      });
    } catch (err) {
      console.error("Bid processing error:", err);
      return res.status(500).json({ error: 'Internal server error' });
    }
  }
);
router.post(
  "/:id/end", // :id là auctionId
  authMiddleware,
  [param("id").isNumeric()],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    try {
      const auctionId = BigInt(req.params.id);
      // Bất kỳ ai cũng có thể gọi kết thúc, nhưng chúng ta hãy
      // dùng ví của người bán (hoặc 1 ví hệ thống) để trả gas
      const user = await User.findById(req.user.id);
      if (!user) return res.status(404).json({ error: "User not found" });
const privateKey = decrypt(user.encryptedPrivateKey, process.env.MASTER_KEY);
      const wallet = new ethers.Wallet(privateKey, provider);

      // (Nên kiểm tra xem đã hết giờ chưa ở đây trước khi gửi)

      const tx = await contract.connect(wallet).endAuction(auctionId);
      const receipt = await tx.wait();

      return res.json({
        success: true,
        message: "Auction ended successfully",
        txHash: receipt.transactionHash,
      });
    } catch (err) {
      console.error(err);
      const reason = err.reason || err.message;
      return res.status(500).json({ error: reason });
    }
  }
);

// ========== API RÚT TIỀN (MỚI) ==========
router.post(
  "/wallet/withdraw",
  authMiddleware,
  [
    body("toAddress").isEthereumAddress().withMessage("Invalid Ethereum address"),
    body("amountEther").isString().notEmpty().withMessage("Amount is required"),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    try {
      const { toAddress, amountEther } = req.body;
      const user = await User.findById(req.user.id);
      if (!user) return res.status(404).json({ error: "User not found" });

      const privateKey = decrypt(user.encryptedPrivateKey, process.env.MASTER_KEY);
      const wallet = new ethers.Wallet(privateKey, provider);

      const amountWei = ethers.utils.parseUnits(amountEther, "ether");
      const balance = await provider.getBalance(wallet.address);
      const { gasPrice } = await provider.getFeeData();

      // Ước lượng gas (21000 là gas limit chuẩn)
      const gasLimit = 21000n; // Dùng BigInt
      const gasCost = gasLimit * gasPrice;
      
      if (balance < (amountWei + gasCost)) {
         return res.status(400).json({ error: "Insufficient funds for withdrawal + gas" });
      }
      
      const tx = await wallet.sendTransaction({
          to: toAddress,
          value: amountWei
      });
      
      await tx.wait();
      
      return res.json({ success: true, txHash: tx.hash, amountSent: amountEther });
      
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: err.message });
    }
  }
);


// ========== API LẤY DỮ LIỆU AUCTIONS ==========

// Lấy tất cả phiên đấu giá active (đã được duyệt)
router.get("/all", async (req, res) => {
  try {
    const auctions = await Auction.find({
      status: { $in: [AUCTION_STATUS.ACTIVE, AUCTION_STATUS.APPROVED] },
      start_time: { $lte: new Date() } // Đã đến thời gian bắt đầu
    })
      .populate('seller_id', 'username full_name')
      .populate('highest_bidder_id', 'username full_name')
      .sort({ end_time: 1 }); // Sắp hết hạn trước

    // Convert prices to VND for display
    const auctionsWithVnd = auctions.map(auction => ({
      ...auction.toObject(),
      start_price_vnd: weiToVnd(auction.start_price.toString()),
      current_price_vnd: weiToVnd(auction.current_price.toString()),
      step_price_vnd: weiToVnd(auction.step_price.toString()),
      formatted_start_price: formatVnd(weiToVnd(auction.start_price.toString())),
      formatted_current_price: formatVnd(weiToVnd(auction.current_price.toString())),
      formatted_step_price: formatVnd(weiToVnd(auction.step_price.toString()))
    }));

    res.json(auctionsWithVnd);
  } catch (err) {
    console.error('Error fetching auctions:', err);
    res.status(500).json({ error: err.message });
  }
});

// Lấy chi tiết 1 phiên đấu giá
router.get("/:id", [param("id").isMongoId()], async (req, res) => {
    try {
        const auction = await Auction.findById(req.params.id)
          .populate('seller_id', 'full_name email')
          .populate('highest_bidder_id', 'full_name');

        if (!auction) {
          return res.status(404).json({ error: "Auction not found" });
        }

        // Get bid history
        const bids = await Bid.find({ auction_id: req.params.id })
          .populate('user_id', 'full_name')
          .sort({ created_at: -1 });

        const auctionWithVnd = {
          ...auction.toObject(),
          start_price_vnd: weiToVnd(auction.start_price.toString()),
          current_price_vnd: weiToVnd(auction.current_price.toString()),
          step_price_vnd: weiToVnd(auction.step_price.toString()),
          formatted_start_price: formatVnd(weiToVnd(auction.start_price.toString())),
          formatted_current_price: formatVnd(weiToVnd(auction.current_price.toString())),
          formatted_step_price: formatVnd(weiToVnd(auction.step_price.toString())),
          bids: bids.map(bid => ({
            ...bid.toObject(),
            amount_vnd: weiToVnd(bid.amount_wei.toString()),
            formatted_amount: formatVnd(weiToVnd(bid.amount_wei.toString()))
          }))
        };

        res.json(auctionWithVnd);
    } catch (err) {
        console.error('Error fetching auction details:', err);
        res.status(500).json({ error: err.message });
    }
});

// ========== API DEPOSIT (Nạp tiền) ==========
router.post("/wallet/deposit", authMiddleware, [
  body("amount_vnd").isFloat({ min: 1000 }).withMessage("Minimum deposit is 1,000 VND"),
  body("momo_ref_id").optional().isString()
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  try {
    const { amount_vnd, momo_ref_id } = req.body;
    const user = await User.findById(req.user.id);

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    // Convert VND to ETH
    const amountEth = amount_vnd / EXCHANGE_RATE.ETH_TO_VND;

    // Create transaction record
    const transaction = new Transaction({
      user_id: user._id,
      type: TRANSACTION_TYPES.DEPOSIT,
      amount_vnd,
      amount_eth: amountEth,
      exchange_rate: EXCHANGE_RATE.ETH_TO_VND,
      status: 'COMPLETED', // Assume instant completion for demo
      momo_ref_id,
      created_at: new Date()
    });
    await transaction.save();

    // Update user balance
    await User.findByIdAndUpdate(user._id, {
      $inc: { balance_eth: amountEth }
    });

    // Create notification
    const notification = new Notification({
      user_id: user._id,
      type: 'DEPOSIT_SUCCESS',
      title: 'Nạp tiền thành công',
      message: `Bạn đã nạp thành công ${formatVnd(amount_vnd)} vào tài khoản.`,
    });
    await notification.save();

    res.json({
      success: true,
      message: 'Deposit successful',
      amount_vnd,
      amount_eth,
      formatted_amount: formatVnd(amount_vnd),
      transaction_id: transaction._id
    });

  } catch (error) {
    console.error('Deposit error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ========== API WITHDRAW (Rút tiền) ==========
router.post("/wallet/withdraw", authMiddleware, [
  body("amount_vnd").isFloat({ min: 1000 }).withMessage("Minimum withdrawal is 1,000 VND")
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  try {
    const { amount_vnd } = req.body;
    const user = await User.findById(req.user.id);

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    // Convert VND to ETH
    const amountEth = amount_vnd / EXCHANGE_RATE.ETH_TO_VND;

    // Check available balance
    const availableEth = parseFloat(user.balance_eth.toString()) - parseFloat(user.locked_eth.toString());

    if (availableEth < amountEth) {
      return res.status(400).json({
        error: 'Insufficient available balance',
        available_vnd: ethToVnd(availableEth),
        formatted_available: formatVnd(ethToVnd(availableEth))
      });
    }

    // Create transaction record (pending)
    const transaction = new Transaction({
      user_id: user._id,
      type: TRANSACTION_TYPES.WITHDRAW,
      amount_vnd,
      amount_eth: amountEth,
      exchange_rate: EXCHANGE_RATE.ETH_TO_VND,
      status: 'PENDING',
      created_at: new Date()
    });
    await transaction.save();

    // For demo purposes, immediately complete the withdrawal
    // In real implementation, this would integrate with Momo API
    await Transaction.findByIdAndUpdate(transaction._id, {
      status: 'COMPLETED'
    });

    // Deduct from user balance
    await User.findByIdAndUpdate(user._id, {
      $inc: { balance_eth: -amountEth }
    });

    // Create notification
    const notification = new Notification({
      user_id: user._id,
      type: 'WITHDRAW_SUCCESS',
      title: 'Rút tiền thành công',
      message: `Bạn đã rút thành công ${formatVnd(amount_vnd)} từ tài khoản.`,
    });
    await notification.save();

    res.json({
      success: true,
      message: 'Withdrawal successful',
      amount_vnd,
      amount_eth,
      formatted_amount: formatVnd(amount_vnd),
      transaction_id: transaction._id
    });

  } catch (error) {
    console.error('Withdrawal error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ========== API GET TRANSACTIONS ==========
router.get("/wallet/transactions", authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    const transactions = await Transaction.find({ user_id: user._id })
      .sort({ created_at: -1 })
      .limit(50);

    res.json({
      transactions: transactions.map(tx => ({
        ...tx.toObject(),
        formatted_amount_vnd: tx.amount_vnd ? formatVnd(tx.amount_vnd) : null,
        formatted_amount_eth: tx.amount_eth ? `${parseFloat(tx.amount_eth.toString()).toFixed(6)} ETH` : null
      }))
    });

  } catch (error) {
    console.error('Get transactions error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ========== ADMIN/MANAGER APIs ==========

// Xem danh sách auctions pending approval
router.get("/admin/pending-approvals", authMiddleware, async (req, res) => {
    try {
        const user = await User.findById(req.user.id);
        if (!user || !['ADMIN', 'MANAGER'].includes(user.role)) {
            return res.status(403).json({ error: "Admin/Manager access required" });
        }

        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;
        const skip = (page - 1) * limit;

        const auctions = await Auction.find({ status: AUCTION_STATUS.PENDING_APPROVAL })
            .populate('seller_id', 'username full_name email')
            .populate('category_id', 'name')
            .sort({ created_at: -1 })
            .skip(skip)
            .limit(limit);

        const total = await Auction.countDocuments({ status: AUCTION_STATUS.PENDING_APPROVAL });

        // Format response with VND
        const formattedAuctions = auctions.map(auction => ({
            id: auction._id,
            title: auction.title,
            description: auction.description,
            seller: {
                id: auction.seller_id._id,
                username: auction.seller_id.username,
                full_name: auction.seller_id.full_name,
                email: auction.seller_id.email
            },
            category: auction.category_id?.name || 'Uncategorized',
            images: auction.images,
            start_price_vnd: weiToVnd(auction.start_price.toString()),
            step_price_vnd: weiToVnd(auction.step_price.toString()),
            formatted_start_price: formatVnd(weiToVnd(auction.start_price.toString())),
            formatted_step_price: formatVnd(weiToVnd(auction.step_price.toString())),
            end_time: auction.end_time,
            created_at: auction.created_at
        }));

        res.json({
            auctions: formattedAuctions,
            pagination: {
                page,
                limit,
                total,
                pages: Math.ceil(total / limit)
            }
        });

    } catch (error) {
        console.error('Get pending approvals error:', error);
        res.status(500).json({ error: 'Failed to get pending approvals' });
    }
});

// Approve auction
router.post("/admin/approve/:auctionId", authMiddleware, async (req, res) => {
    try {
        const { auctionId } = req.params;
        const adminId = req.user.id;

        const admin = await User.findById(adminId);
        if (!admin || !['ADMIN', 'MANAGER'].includes(admin.role)) {
            return res.status(403).json({ error: "Admin/Manager access required" });
        }

        const auction = await Auction.findById(auctionId).populate('seller_id');
        if (!auction) {
            return res.status(404).json({ error: "Auction not found" });
        }

        if (auction.status !== AUCTION_STATUS.PENDING_APPROVAL) {
            return res.status(400).json({ error: "Auction is not pending approval" });
        }

        // Deploy smart contract
        try {
            const contractAddress = await deployAuctionContract(auction);

            // Update auction status
            await Auction.findByIdAndUpdate(auctionId, {
                status: AUCTION_STATUS.APPROVED,
                approved_by: adminId,
                approved_at: new Date(),
                contract_address: contractAddress,
                start_time: new Date() // Set start time when approved
            });

            // Create notification for seller
            const Notification = require('../models/Notification');
            await Notification.create({
                user_id: auction.seller_id._id,
                type: 'AUCTION_APPROVED',
                title: 'Phiên đấu giá đã được duyệt',
                message: `Phiên đấu giá "${auction.title}" đã được duyệt và sẽ bắt đầu sớm.`,
                related_id: auctionId
            });

            // Emit socket event
            const io = req.app.get('io');
            io.to(`user_${auction.seller_id._id}`).emit('auction_approved', {
                auction_id: auctionId,
                title: auction.title,
                contract_address: contractAddress
            });

            res.json({
                success: true,
                message: `Auction "${auction.title}" has been approved`,
                auction_id: auctionId,
                contract_address: contractAddress,
                approved_by: admin.username || admin.full_name
            });

        } catch (deployError) {
            console.error('Contract deployment failed:', deployError);

            // Update status to DEPLOYING_FAILED
            await Auction.findByIdAndUpdate(auctionId, {
                status: AUCTION_STATUS.REJECTED,
                rejection_reason: 'Failed to deploy smart contract: ' + deployError.message,
                approved_by: adminId,
                approved_at: new Date()
            });

            res.status(500).json({
                error: 'Failed to deploy smart contract',
                details: deployError.message
            });
        }

    } catch (error) {
        console.error('Approve auction error:', error);
        res.status(500).json({ error: 'Failed to approve auction' });
    }
});

// Reject auction
router.post("/admin/reject/:auctionId", authMiddleware, [
    body('reason').isString().notEmpty().withMessage('Rejection reason is required')
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    try {
        const { auctionId } = req.params;
        const { reason } = req.body;
        const adminId = req.user.id;

        const admin = await User.findById(adminId);
        if (!admin || !['ADMIN', 'MANAGER'].includes(admin.role)) {
            return res.status(403).json({ error: "Admin/Manager access required" });
        }

        const auction = await Auction.findById(auctionId).populate('seller_id');
        if (!auction) {
            return res.status(404).json({ error: "Auction not found" });
        }

        if (auction.status !== AUCTION_STATUS.PENDING_APPROVAL) {
            return res.status(400).json({ error: "Auction is not pending approval" });
        }

        // Update auction status
        await Auction.findByIdAndUpdate(auctionId, {
            status: AUCTION_STATUS.REJECTED,
            approved_by: adminId,
            approved_at: new Date(),
            rejection_reason: reason
        });

        // Create notification for seller
        const Notification = require('../models/Notification');
        await Notification.create({
            user_id: auction.seller_id._id,
            type: 'AUCTION_REJECTED',
            title: 'Phiên đấu giá bị từ chối',
            message: `Phiên đấu giá "${auction.title}" đã bị từ chối. Lý do: ${reason}`,
            related_id: auctionId
        });

        // Emit socket event
        const io = req.app.get('io');
        io.to(`user_${auction.seller_id._id}`).emit('auction_rejected', {
            auction_id: auctionId,
            title: auction.title,
            reason: reason
        });

        res.json({
            success: true,
            message: `Auction "${auction.title}" has been rejected`,
            auction_id: auctionId,
            reason: reason,
            rejected_by: admin.username || admin.full_name
        });

    } catch (error) {
        console.error('Reject auction error:', error);
        res.status(500).json({ error: 'Failed to reject auction' });
    }
});

// Get all auctions with filtering (Admin)
router.get("/admin/all", authMiddleware, async (req, res) => {
    try {
        const user = await User.findById(req.user.id);
        if (!user || !['ADMIN', 'MANAGER'].includes(user.role)) {
            return res.status(403).json({ error: "Admin/Manager access required" });
        }

        const { status, page = 1, limit = 20 } = req.query;
        const query = status ? { status } : {};
        const skip = (page - 1) * limit;

        const auctions = await Auction.find(query)
            .populate('seller_id', 'username full_name email')
            .populate('approved_by', 'username full_name')
            .populate('highest_bidder_id', 'username full_name')
            .sort({ created_at: -1 })
            .skip(skip)
            .limit(limit);

        const total = await Auction.countDocuments(query);

        // Format response
        const formattedAuctions = auctions.map(auction => ({
            id: auction._id,
            title: auction.title,
            status: auction.status,
            seller: {
                username: auction.seller_id?.username,
                full_name: auction.seller_id?.full_name,
                email: auction.seller_id?.email
            },
            approved_by: auction.approved_by ? {
                username: auction.approved_by.username,
                full_name: auction.approved_by.full_name
            } : null,
            highest_bidder: auction.highest_bidder_id ? {
                username: auction.highest_bidder_id.username,
                full_name: auction.highest_bidder_id.full_name
            } : null,
            start_price_vnd: weiToVnd(auction.start_price.toString()),
            current_price_vnd: weiToVnd(auction.current_price.toString()),
            formatted_current_price: formatVnd(weiToVnd(auction.current_price.toString())),
            rejection_reason: auction.rejection_reason,
            contract_address: auction.contract_address,
            created_at: auction.created_at,
            approved_at: auction.approved_at,
            start_time: auction.start_time,
            end_time: auction.end_time
        }));

        res.json({
            auctions: formattedAuctions,
            pagination: {
                page: parseInt(page),
                limit: parseInt(limit),
                total,
                pages: Math.ceil(total / limit)
            }
        });

    } catch (error) {
        console.error('Get admin auctions error:', error);
        res.status(500).json({ error: 'Failed to get auctions' });
    }
});



module.exports = router;