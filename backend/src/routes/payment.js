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

/**
 * TẠO REQUEST NẠP TIỀN VND
 * User tạo request nạp VND qua Momo
 */
router.post('/deposit/request', authMiddleware, [
  body('amount_vnd').isFloat({ min: 10000, max: 50000000 }).withMessage('Amount must be between 10,000 - 50,000,000 VND')
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  try {
    const { amount_vnd } = req.body;
    const userId = req.user.id;

    // Convert VND to ETH
    const amountEth = vndToEth(amount_vnd);

    // Generate unique order ID
    const orderId = `BIDCHAIN_${Date.now()}_${userId}`;

    // Create deposit request
    const depositRequest = new DepositRequest({
      user_id: userId,
      amount_vnd,
      amount_eth: amountEth,
      exchange_rate: EXCHANGE_RATE.ETH_TO_VND,
      momo_order_id: orderId,
      status: 'PENDING_PAYMENT'
    });

    await depositRequest.save();

    // Create Momo payment
    const momoPayment = await momoService.createPayment(amount_vnd, orderId);

    if (!momoPayment.success) {
      // Update status to failed
      await DepositRequest.findByIdAndUpdate(depositRequest._id, {
        status: 'FAILED',
        notes: momoPayment.error
      });

      return res.status(500).json({
        error: 'Failed to create payment',
        details: momoPayment.error
      });
    }

    // Update with payment URLs
    await DepositRequest.findByIdAndUpdate(depositRequest._id, {
      momo_qr_url: momoPayment.qrCodeUrl,
      momo_qr_code: momoPayment.payUrl
    });

    res.json({
      success: true,
      deposit_request_id: depositRequest._id,
      amount_vnd,
      amount_eth,
      formatted_amount: formatVnd(amount_vnd),
      momo_payment: {
        order_id: orderId,
        pay_url: momoPayment.payUrl,
        qr_code_url: momoPayment.qrCodeUrl,
        deeplink: momoPayment.deeplink
      },
      instructions: [
        '1. Quét mã QR hoặc click vào pay_url',
        '2. Thanh toán qua app Momo',
        '3. Chờ admin duyệt (thường trong vài phút)',
        '4. ETH sẽ được nạp vào ví của bạn'
      ]
    });

  } catch (error) {
    console.error('Create deposit request error:', error);
    res.status(500).json({ error: 'Failed to create deposit request' });
  }
});

/**
 * MOMO CALLBACK
 * Momo gọi về khi user thanh toán thành công
 */
router.post('/momo/callback', async (req, res) => {
  try {
    const callbackData = req.body;

    console.log('Momo callback received:', callbackData);

    // Verify signature
    const isValidSignature = momoService.verifyCallback(callbackData);

    if (!isValidSignature) {
      console.error('Invalid Momo signature');
      return res.status(400).json({ error: 'Invalid signature' });
    }

    // Process payment result
    const paymentResult = momoService.processPaymentSuccess(callbackData);

    // Update deposit request
    const depositRequest = await DepositRequest.findOne({
      momo_order_id: callbackData.orderId
    });

    if (!depositRequest) {
      console.error('Deposit request not found:', callbackData.orderId);
      return res.status(404).json({ error: 'Deposit request not found' });
    }

    if (paymentResult.success) {
      // Payment successful
      await DepositRequest.findByIdAndUpdate(depositRequest._id, {
        status: 'PAID',
        paid_at: new Date()
      });

      console.log(`Payment successful for order ${callbackData.orderId}`);
    } else {
      // Payment failed
      await DepositRequest.findByIdAndUpdate(depositRequest._id, {
        status: 'FAILED',
        notes: paymentResult.error
      });

      console.log(`Payment failed for order ${callbackData.orderId}`);
    }

    // Always return success to Momo
    res.json({ success: true });

  } catch (error) {
    console.error('Momo callback processing error:', error);
    res.status(500).json({ error: 'Callback processing failed' });
  }
});

/**
 * ADMIN: APPROVE DEPOSIT REQUEST
 * Admin duyệt và fund ETH vào user wallet
 */
router.post('/admin/approve-deposit/:requestId', authMiddleware, async (req, res) => {
  try {
    const { requestId } = req.params;
    const adminId = req.user.id;

    // Check if admin
    const admin = await User.findById(adminId);
    if (admin.role !== 'ADMIN') {
      return res.status(403).json({ error: 'Admin access required' });
    }

    // Get deposit request
    const depositRequest = await DepositRequest.findById(requestId).populate('user_id');
    if (!depositRequest) {
      return res.status(404).json({ error: 'Deposit request not found' });
    }

    if (depositRequest.status !== 'PAID') {
      return res.status(400).json({ error: 'Request must be in PAID status' });
    }

    // Get admin wallet
    const adminWallet = walletFromPrivateKey(process.env.ADMIN_PRIVATE_KEY);

    // Convert VND to Wei for transfer
    const amountEth = parseFloat(depositRequest.amount_eth.toString());
    const amountWei = ethers.utils.parseEther(amountEth.toString());

    // Check admin balance
    const adminBalance = await provider.getBalance(adminWallet.address);
    if (adminBalance.lt(amountWei)) {
      return res.status(400).json({
        error: 'Insufficient admin balance',
        required: amountEth + ' ETH',
        available: ethers.utils.formatEther(adminBalance) + ' ETH'
      });
    }

    // Transfer ETH from admin to user
    const tx = await adminWallet.sendTransaction({
      to: depositRequest.user_id.wallet_address,
      value: amountWei
    });

    const receipt = await tx.wait();

    // Update deposit request
    await DepositRequest.findByIdAndUpdate(depositRequest._id, {
      status: 'COMPLETED',
      approved_by: adminId,
      approved_at: new Date(),
      completed_at: new Date(),
      funding_tx_hash: receipt.transactionHash
    });

    // Update user balance
    await User.findByIdAndUpdate(depositRequest.user_id._id, {
      $inc: { balance_eth: toWei(amountEth.toString()) }
    });

    // Create transaction record
    const transaction = new Transaction({
      user_id: depositRequest.user_id._id,
      type: TRANSACTION_TYPES.DEPOSIT,
      amount_vnd: depositRequest.amount_vnd,
      amount_eth: amountEth,
      exchange_rate: EXCHANGE_RATE.ETH_TO_VND,
      status: 'COMPLETED',
      tx_hash: receipt.transactionHash,
      momo_ref_id: depositRequest.momo_order_id
    });
    await transaction.save();

    res.json({
      success: true,
      message: `Approved deposit of ${formatVnd(depositRequest.amount_vnd)} for ${depositRequest.user_id.username}`,
      deposit_request_id: depositRequest._id,
      user_funded: depositRequest.user_id.username,
      amount_eth: amountEth,
      tx_hash: receipt.transactionHash
    });

  } catch (error) {
    console.error('Approve deposit error:', error);
    res.status(500).json({ error: 'Failed to approve deposit' });
  }
});

/**
 * ADMIN: REJECT DEPOSIT REQUEST
 */
router.post('/admin/reject-deposit/:requestId', authMiddleware, [
  body('reason').notEmpty().withMessage('Rejection reason required')
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  try {
    const { requestId } = req.params;
    const { reason } = req.body;
    const adminId = req.user.id;

    // Check if admin
    const admin = await User.findById(adminId);
    if (admin.role !== 'ADMIN') {
      return res.status(403).json({ error: 'Admin access required' });
    }

    const depositRequest = await DepositRequest.findByIdAndUpdate(requestId, {
      status: 'REJECTED',
      approved_by: adminId,
      approved_at: new Date(),
      rejection_reason: reason
    }, { new: true }).populate('user_id');

    if (!depositRequest) {
      return res.status(404).json({ error: 'Deposit request not found' });
    }

    res.json({
      success: true,
      message: `Rejected deposit request for ${depositRequest.user_id.username}`,
      reason: reason
    });

  } catch (error) {
    console.error('Reject deposit error:', error);
    res.status(500).json({ error: 'Failed to reject deposit' });
  }
});

/**
 * GET DEPOSIT REQUESTS
 * User xem lịch sử request nạp tiền
 */
router.get('/deposit/history', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;
    const requests = await DepositRequest.find({ user_id: userId })
      .sort({ created_at: -1 })
      .limit(50);

    res.json({
      deposit_requests: requests.map(req => ({
        id: req._id,
        amount_vnd: parseFloat(req.amount_vnd.toString()),
        amount_eth: parseFloat(req.amount_eth.toString()),
        formatted_amount: formatVnd(parseFloat(req.amount_vnd.toString())),
        status: req.status,
        momo_order_id: req.momo_order_id,
        created_at: req.created_at,
        paid_at: req.paid_at,
        completed_at: req.completed_at,
        qr_code_url: req.momo_qr_url
      }))
    });

  } catch (error) {
    console.error('Get deposit history error:', error);
    res.status(500).json({ error: 'Failed to get deposit history' });
  }
});

/**
 * ADMIN: GET ALL DEPOSIT REQUESTS
 */
router.get('/admin/deposit-requests', authMiddleware, async (req, res) => {
  try {
    // Check if admin
    const admin = await User.findById(req.user.id);
    if (admin.role !== 'ADMIN') {
      return res.status(403).json({ error: 'Admin access required' });
    }

    const { status } = req.query;
    const query = status ? { status } : {};

    const requests = await DepositRequest.find(query)
      .populate('user_id', 'username email')
      .populate('approved_by', 'username')
      .sort({ created_at: -1 })
      .limit(100);

    res.json({
      deposit_requests: requests.map(req => ({
        id: req._id,
        user: {
          id: req.user_id._id,
          username: req.user_id.username,
          email: req.user_id.email
        },
        amount_vnd: parseFloat(req.amount_vnd.toString()),
        amount_eth: parseFloat(req.amount_eth.toString()),
        formatted_amount: formatVnd(parseFloat(req.amount_vnd.toString())),
        status: req.status,
        momo_order_id: req.momo_order_id,
        qr_code_url: req.momo_qr_url,
        created_at: req.created_at,
        paid_at: req.paid_at,
        approved_at: req.approved_at,
        approved_by: req.approved_by?.username,
        rejection_reason: req.rejection_reason
      }))
    });

  } catch (error) {
    console.error('Get deposit requests error:', error);
    res.status(500).json({ error: 'Failed to get deposit requests' });
  }
});

module.exports = router;
