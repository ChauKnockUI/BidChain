const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const { authMiddleware } = require('../middleware/auth');

const DepositRequest = require('../models/DepositRequest');
const User = require('../models/User');
const Transaction = require('../models/Transaction');

const momoService = require('../services/momo.service');
const { vndToEth, ethToVnd, formatVnd } = require('../utils/conversion');
const { EXCHANGE_RATE, TRANSACTION_TYPES } = require('../config/constants');

const { ethers } = require('ethers');
const { walletFromPrivateKey, provider } = require('../blockchain/contract');

// ======================================================
// 1) USER TẠO YÊU CẦU NẠP TIỀN (VND → ETH) - Với auto-check sau 10p
// ======================================================
router.post(
  '/deposit/request',
  authMiddleware,
  [body('amount_vnd').isFloat({ min: 10000, max: 50000000 })],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    try {
      const { amount_vnd } = req.body;
      const userId = req.user.id;

      // Tạo orderId duy nhất
      const orderId = `BIDCHAIN_${Date.now()}_${userId}`;
      console.log('Created orderId:', orderId);

      // Convert VND → ETH
      const amountEth = vndToEth(amount_vnd);
      console.log('amountEth:', amountEth);

      // Lưu deposit request
      const depositRequest = await DepositRequest.create({
        user_id: userId,
        amount_vnd,
        amount_eth: amountEth,
        exchange_rate: EXCHANGE_RATE.ETH_TO_VND,
        momo_order_id: orderId,
        status: 'PENDING_PAYMENT'
      });

      // Tạo thanh toán MoMo
      const momoPayment = await momoService.createPayment(amount_vnd, orderId);

      if (!momoPayment.success) {
        await DepositRequest.findByIdAndUpdate(depositRequest._id, {
          status: 'FAILED',
          notes: momoPayment.error
        });

        return res.status(500).json({
          error: 'Failed to create payment',
          details: momoPayment.error
        });
      }

      await DepositRequest.findByIdAndUpdate(depositRequest._id, {
        momo_qr_url: momoPayment.qrCodeUrl,
        momo_qr_code: momoPayment.payUrl
      });

      // Return ngay cho user (hiển thị QR/payUrl)
      res.json({
        success: true,
        deposit_request_id: depositRequest._id,
        amount_vnd,
        amount_eth: amountEth,
        momo_payment: {
          payUrl: momoPayment.payUrl,      // Deeplink
          qrCodeUrl: momoPayment.qrCodeUrl // QR image URL
        },
        formatted_amount: formatVnd(amount_vnd),
        message: 'Payment created. Please pay within 30s for auto-check.'
      });

      // BACKGROUND: Đợi 30s rồi check status tự động (fallback nếu callback fail)
      // AUTO-CHECK: Nếu PAID → chuyển ETH luôn
setTimeout(async () => {
  try {
    console.log(`Auto-checking status for orderId: ${orderId}`);
    const status = await momoService.checkTransactionStatus(orderId);

    if (status.resultCode === 0) {
      const deposit = await DepositRequest.findById(depositRequest._id).populate('user_id');

      if (!deposit || deposit.status === "COMPLETED") return;

      const adminWallet = walletFromPrivateKey(process.env.ADMIN_PRIVATE_KEY);
      const amountWei = ethers.utils.parseEther(deposit.amount_eth.toString());
      const balance = await provider.getBalance(adminWallet.address);

      if (balance.lt(amountWei)) {
        await DepositRequest.findByIdAndUpdate(deposit._id, {
          status: "FAILED",
          notes: "Admin wallet insufficient ETH"
        });
        return;
      }

      const tx = await adminWallet.sendTransaction({
        to: deposit.user_id.wallet_address,
        value: amountWei
      });
      const receipt = await tx.wait();

      // Update deposit
      await DepositRequest.findByIdAndUpdate(deposit._id, {
        status: "COMPLETED",
        paid_at: new Date(),
        momo_trans_id: status.transId || "",
        funding_tx_hash: receipt.transactionHash
      });

      // Update user balance
      await User.findByIdAndUpdate(deposit.user_id._id, {
        $inc: { balance_eth: parseFloat(deposit.amount_eth) }
      });

      // Log transaction
      await Transaction.create({
        user_id: deposit.user_id._id,
        type: TRANSACTION_TYPES.DEPOSIT,
        amount_vnd: deposit.amount_vnd,
        amount_eth: deposit.amount_eth,
        status: 'COMPLETED',
        tx_hash: receipt.transactionHash,
        momo_ref_id: deposit.momo_order_id,
        exchange_rate: EXCHANGE_RATE.ETH_TO_VND
      });

      console.log(`Order ${orderId} COMPLETED via auto-check`);
      return;
    }

    // THẤT BẠI
    await DepositRequest.findByIdAndUpdate(depositRequest._id, {
      status: "FAILED",
      notes: status.message || "Payment failed"
    });

    console.log(`Order ${orderId} FAILED: ${status.message}`);

  } catch (err) {
    console.error(`Auto-check error for ${orderId}:`, err);
    await DepositRequest.findByIdAndUpdate(depositRequest._id, {
      status: "TIMEOUT",
      notes: "Auto-check failed"
    });
  }
}, 60000);


    } catch (err) {
      console.error('Create deposit request error:', err);
      res.status(500).json({ error: 'Failed to create deposit request', details: err.message });
    }
  }
);


// ======================================================
// 2) CHECK TRẠNG THÁI MOMO
// ======================================================
router.post(
  '/momo/check-status',
  [body('orderId').notEmpty().trim().isString().withMessage('OrderId must be a non-empty string')],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    try {
      const { orderId } = req.body;

      const status = await momoService.checkTransactionStatus(orderId);

      res.json({ success: true, momo_status: status });

    } catch (err) {
      console.error('Status error:', err);
      res.status(500).json({ error: 'Failed to check momo status', details: err.message });
    }
  }
);

// ======================================================
// 3) MOMO CALLBACK — luôn trả về 200 OK (real-time update)
// ======================================================
// ======================================================
// MOMO CALLBACK — PAID → Chuyển ETH luôn
// ======================================================
router.post('/momo/callback', async (req, res) => {
  try {
    const data = req.body;

    console.log("MOMO CALLBACK:", data);

    const isValid = momoService.verifyCallback(data);
    if (!isValid) return res.status(400).json({ error: "Invalid signature" });

    const deposit = await DepositRequest.findOne({
      momo_order_id: data.orderId
    }).populate('user_id');

    if (!deposit) {
      return res.status(404).json({ error: "Deposit request not found" });
    }

    // ❗ Nếu callback đã gửi và request DONE rồi → bỏ qua
    if (["COMPLETED"].includes(deposit.status)) {
      return res.json({ success: true });
    }

    // ❗ MoMo trả về thành công
    if (data.resultCode === 0) {
      // Chuyển ETH cho user
      const adminWallet = walletFromPrivateKey(process.env.ADMIN_PRIVATE_KEY);
      const amountWei = ethers.utils.parseEther(deposit.amount_eth.toString());
      const balance = await provider.getBalance(adminWallet.address);

      if (balance.lt(amountWei)) {
        await DepositRequest.findByIdAndUpdate(deposit._id, {
          status: "FAILED",
          notes: "Admin wallet insufficient ETH"
        });
        return res.json({ error: "Admin wallet insufficient ETH" });
      }

      // Gửi ETH
      const tx = await adminWallet.sendTransaction({
        to: deposit.user_id.wallet_address,
        value: amountWei
      });
      const receipt = await tx.wait();

      // Cập nhật deposit
      await DepositRequest.findByIdAndUpdate(deposit._id, {
        status: "COMPLETED",
        paid_at: new Date(),
        momo_trans_id: data.transId || "",
        funding_tx_hash: receipt.transactionHash
      });

      // Update balance user
      await User.findByIdAndUpdate(deposit.user_id._id, {
        $inc: { balance_eth: parseFloat(deposit.amount_eth) }
      });

      // Log transaction
      await Transaction.create({
        user_id: deposit.user_id._id,
        type: TRANSACTION_TYPES.DEPOSIT,
        amount_vnd: deposit.amount_vnd,
        amount_eth: deposit.amount_eth,
        status: 'COMPLETED',
        tx_hash: receipt.transactionHash,
        momo_ref_id: deposit.momo_order_id,
        exchange_rate: EXCHANGE_RATE.ETH_TO_VND
      });

      return res.json({ success: true });
    }

    // ❗ MoMo báo thất bại
    await DepositRequest.findByIdAndUpdate(deposit._id, {
      status: "FAILED",
      notes: data.message
    });

    return res.json({ success: true });

  } catch (err) {
    console.error("Callback processing error:", err);
    res.status(500).json({ error: "Callback failed" });
  }
});


// ======================================================
// 4) ADMIN APPROVE — CHUYỂN ETH
// ======================================================
router.post('/admin/approve-deposit/:requestId', authMiddleware, async (req, res) => {
  try {
    const { requestId } = req.params;

    const admin = await User.findById(req.user.id);
    if (admin.role !== 'ADMIN')
      return res.status(403).json({ error: 'Admin access required' });

    const deposit = await DepositRequest.findById(requestId).populate('user_id');
    if (!deposit) return res.status(404).json({ error: 'Request not found' });
    if (deposit.status !== 'PAID')
      return res.status(400).json({ error: 'Request must be PAID' });

    const adminWallet = walletFromPrivateKey(process.env.ADMIN_PRIVATE_KEY);

    const amountWei = ethers.utils.parseEther(deposit.amount_eth.toString());
    const balance = await provider.getBalance(adminWallet.address);

    if (balance.lt(amountWei))
      return res.status(400).json({ error: 'Admin wallet insufficient ETH' });

    // Transfer
    const tx = await adminWallet.sendTransaction({
      to: deposit.user_id.wallet_address,
      value: amountWei
    });
    const receipt = await tx.wait();

    await DepositRequest.findByIdAndUpdate(deposit._id, {
      status: 'COMPLETED',
      approved_by: req.user.id,
      approved_at: new Date(),
      funding_tx_hash: receipt.transactionHash
    });

    await User.findByIdAndUpdate(deposit.user_id._id, {
      $inc: { balance_eth: parseFloat(deposit.amount_eth) }
    });

    await Transaction.create({
      user_id: deposit.user_id._id,
      type: TRANSACTION_TYPES.DEPOSIT,
      amount_vnd: deposit.amount_vnd,
      amount_eth: deposit.amount_eth,
      status: 'COMPLETED',
      tx_hash: receipt.transactionHash,
      momo_ref_id: deposit.momo_order_id,
      exchange_rate: EXCHANGE_RATE.ETH_TO_VND
    });

    res.json({
      success: true,
      tx_hash: receipt.transactionHash,
      message: 'Deposit approved & ETH transferred'
    });

  } catch (err) {
    console.error('Approve error:', err);
    res.status(500).json({ error: 'Failed to approve deposit' });
  }
});

// ======================================================
// 6) ADMIN REJECT
// ======================================================
router.post(
  '/admin/reject-deposit/:requestId',
  authMiddleware,
  [body('reason').notEmpty()],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    try {
      const { requestId } = req.params;
      const { reason } = req.body;

      const admin = await User.findById(req.user.id);
      if (admin.role !== 'ADMIN')
        return res.status(403).json({ error: 'Admin access required' });

      const deposit = await DepositRequest.findByIdAndUpdate(
        requestId,
        {
          status: 'REJECTED',
          rejection_reason: reason,
          approved_by: req.user.id,
          approved_at: new Date()
        },
        { new: true }
      );

      if (!deposit) return res.status(404).json({ error: 'Request not found' });

      res.json({ success: true, message: 'Deposit request rejected' });

    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to reject deposit' });
    }
  }
);

// ======================================================
// 7) USER LỊCH SỬ NẠP TIỀN
// ======================================================
router.get('/deposit/history', authMiddleware, async (req, res) => {
  try {
    const requests = await DepositRequest.find({ user_id: req.user.id })
      .sort({ created_at: -1 });

    res.json({ deposit_requests: requests });

  } catch (err) {
    res.status(500).json({ error: 'Failed to get history' });
  }
});

// ======================================================
// 8) ADMIN GET TẤT CẢ REQUEST
// ======================================================
router.get('/admin/deposit-requests', authMiddleware, async (req, res) => {
  try {
    const admin = await User.findById(req.user.id);
    if (admin.role !== 'ADMIN')
      return res.status(403).json({ error: 'Admin access required' });

    const { status } = req.query;
    const query = status ? { status } : {};

    const requests = await DepositRequest.find(query)
      .populate('user_id', 'username email')
      .populate('approved_by', 'username')
      .sort({ created_at: -1 });

    res.json({ deposit_requests: requests });

  } catch (err) {
    res.status(500).json({ error: 'Failed to get all requests' });
  }
});

module.exports = router;