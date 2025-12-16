const { ethers } = require("ethers");
const { walletFromPrivateKey, provider } = require("../blockchain/contract");
const express = require("express");
const router = express.Router();
const { body, validationResult } = require("express-validator");

const { authMiddleware } = require("../middleware/auth");
const { ethToVnd, formatVnd, toWei, vndToEth } = require("../utils/conversion");
const { EXCHANGE_RATE, TRANSACTION_TYPES } = require("../config/constants");
const DepositRequest = require("../models/DepositRequest");
const momoService = require("../services/momo.service");
const User = require("../models/User");
const Transaction = require("../models/Transaction");
const { emitDepositSuccess } = require("../middleware/socketEmitter");

// ======================================================
// 1) USER TẠO YÊU CẦU NẠP TIỀN (VND → ETH) - Với auto-check 60s fallback
// ======================================================
router.post(
  "/deposit/request",
  authMiddleware,
  [body("amount_vnd").isFloat({ min: 10000, max: 50000000 })],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty())
      return res.status(400).json({ errors: errors.array() });

    try {
      const { amount_vnd } = req.body;
      const userId = req.user.id;

      // Tạo orderId duy nhất
      const orderId = `BIDCHAIN_${Date.now()}_${userId}`;
      console.log("Created orderId:", orderId);

      // Convert VND → ETH string (fixed 18 decimals)
      const amountEthStr = vndToEth(amount_vnd);
      const amountEthNum = parseFloat(amountEthStr);  // Để log/display
      console.log("amountEth:", amountEthStr, "(num:", amountEthNum, ")");

      // Lưu deposit request (amount_eth as string ETH)
      const depositRequest = await DepositRequest.create({
        user_id: userId,
        amount_vnd,
        amount_eth: amountEthStr,
        exchange_rate: EXCHANGE_RATE.ETH_TO_VND,
        momo_order_id: orderId,
        status: "PENDING_PAYMENT",
      });

      // Tạo thanh toán MoMo
      const momoPayment = await momoService.createPayment(amount_vnd, orderId);

      if (!momoPayment.success) {
        await DepositRequest.findByIdAndUpdate(depositRequest._id, {
          status: "FAILED",
          notes: momoPayment.error,
        });

        return res.status(500).json({
          error: "Failed to create payment",
          details: momoPayment.error,
        });
      }

      await DepositRequest.findByIdAndUpdate(depositRequest._id, {
        momo_qr_url: momoPayment.qrCodeUrl,
        momo_qr_code: momoPayment.payUrl,
      });

      // Return ngay cho user (hiển thị QR/payUrl)
      res.json({
        success: true,
        deposit_request_id: depositRequest._id,
        amount_vnd,
        amount_eth: amountEthStr,
        momo_payment: {
          payUrl: momoPayment.payUrl, // Deeplink
          qrCodeUrl: momoPayment.qrCodeUrl, // QR image URL
        },
        formatted_amount: formatVnd(amount_vnd),
        message: "Payment created. Please pay now. System will auto-transfer ETH on success.",
      });

      // FALLBACK: Auto-check sau 60s (nếu callback miss)
      setTimeout(async () => {
        await handlePaymentSuccess(orderId, depositRequest._id, "auto-check");
      }, 60000);

    } catch (err) {
      console.error("Create deposit request error:", err);
      res
        .status(500)
        .json({
          error: "Failed to create deposit request",
          details: err.message,
        });
    }
  }
);

// ======================================================
// Helper: Xử lý thanh toán success → Chuyển ETH ngay
// ======================================================
async function handlePaymentSuccess(orderId, depositId, source = "unknown") {
  try {
    console.log(`${source}: Processing success for orderId: ${orderId}`);
    const status = await momoService.checkTransactionStatus(orderId); // Hoặc dùng data từ callback

    if (status.resultCode !== 0) {
      console.log(`${source}: Payment failed: ${status.message}`);
      return;
    }

    const deposit = await DepositRequest.findById(depositId).populate("user_id");
    if (!deposit || deposit.status === "PAID_DONE") {
      console.log(`${source}: Already processed or not found`);
      return;
    }

    // Parse amount_eth string → Number cho log, wei cho transfer
    const amountEthNum = parseFloat(deposit.amount_eth);
    console.log(
      `${source}: Parsed amount_eth: ${deposit.amount_eth} (num: ${amountEthNum}, type: ${typeof amountEthNum})`
    );
    if (isNaN(amountEthNum) || amountEthNum <= 0) {
      console.error(`${source}: Invalid amount_eth: ${deposit.amount_eth}`);
      await DepositRequest.findByIdAndUpdate(deposit._id, {
        status: "FAILED",
        notes: "Invalid amount",
      });
      return;
    }

    // Bước 1: Update to PAID (MoMo success, chưa ETH)
    await DepositRequest.findByIdAndUpdate(deposit._id, {
      status: "PAID",
      momo_trans_id: status.transId || "",
    });
    console.log(`${source}: Updated to PAID`);

    // Bước 2: Chuyển ETH ngay từ admin → user
    const adminWallet = walletFromPrivateKey(process.env.DEPLOYER_PRIVATE_KEY);
    const amountWeiStr = toWei(deposit.amount_eth);  // ETH string → wei string (an toàn)
    const amountWei = ethers.BigNumber.from(amountWeiStr);  // BigNumber cho ethers
    const balance = await provider.getBalance(adminWallet.address);

    if (balance.lt(amountWei)) {
      await DepositRequest.findByIdAndUpdate(deposit._id, {
        status: "FAILED",
        notes: "Admin wallet insufficient ETH",
      });
      console.error(`${source}: Admin balance low: ${balance.toString()} wei < ${amountWeiStr} wei`);
      return;
    }

    const tx = await adminWallet.sendTransaction({
      to: deposit.user_id.wallet_address,
      value: amountWei,
      gasLimit: 21000,
    });
    const receipt = await tx.wait();
    console.log(`${source}: ETH transfer tx: ${receipt.transactionHash}`);

    // Bước 3: Update to PAID_DONE + balance user (FIXED với BigInt)
    await DepositRequest.findByIdAndUpdate(deposit._id, {
      status: "PAID_DONE",
      paid_at: new Date(),
      funding_tx_hash: receipt.transactionHash,
    });

    // ========== ON-CHAIN DEPOSIT TO BIDCHAINWALLET ==========
    // Deposit to central wallet contract for on-chain balance tracking
    let walletDepositTx = null;
    try {
      const { depositForUser, isWalletContractAvailable } = require('../blockchain/wallet-contract');

      if (isWalletContractAvailable()) {
        console.log(`${source}: Depositing to BidChainWallet contract...`);
        const walletResult = await depositForUser(deposit.user_id.wallet_address, amountWeiStr);
        walletDepositTx = walletResult.txHash;
        console.log(`${source}: ✅ On-chain wallet deposit TX: ${walletDepositTx}`);
      }
    } catch (walletError) {
      console.error(`${source}: ⚠️ BidChainWallet deposit failed:`, walletError.message);
      // Continue - ETH transfer to personal wallet already succeeded
    }

    // Fix balance: Update MongoDB as cache (primary source is now blockchain)
    const user = await User.findById(deposit.user_id._id);
    const currentBalanceWei = BigInt(user.balance_eth || 0n);
    const addAmountWei = ethers.BigNumber.from(amountWeiStr).toBigInt();
    const newBalanceWei = currentBalanceWei + addAmountWei;

    console.log(`${source}: Balance update - Current wei: ${currentBalanceWei}, Add wei: ${addAmountWei}, New wei: ${newBalanceWei}`);

    // Lưu string vào DB (cache - blockchain is source of truth)
    const updateResult = await User.findByIdAndUpdate(
      deposit.user_id._id,
      { $set: { balance_eth: newBalanceWei.toString() } },
      { new: true }
    );
    console.log(`${source}: Updated user balance wei: ${updateResult.balance_eth}`);

    // Log transaction (amount_eth as string ETH cho dễ đọc)
    await Transaction.create({
      user_id: deposit.user_id._id,
      type: TRANSACTION_TYPES.DEPOSIT,
      amount_vnd: deposit.amount_vnd,
      amount_eth: deposit.amount_eth,  // String ETH
      status: "COMPLETED",
      tx_hash: receipt.transactionHash,
      momo_ref_id: deposit.momo_order_id,
      exchange_rate: EXCHANGE_RATE.ETH_TO_VND,
      amount_eth_wei: amountWeiStr  // Thêm field wei nếu cần
    });

    console.log(`${source}: COMPLETED - Order ${orderId}, ETH sent to ${deposit.user_id.wallet_address}`);
    await emitDepositSuccess(deposit.user_id._id, deposit.amount_vnd, global.io);
  } catch (err) {
    console.error(`${source}: Error processing ${orderId}:`, err);
    await DepositRequest.findByIdAndUpdate(depositId, {
      status: "TIMEOUT",
      notes: "Process failed",
    });
  }
}

// ======================================================
// MOMO CALLBACK/IPN — Trigger realtime khi MoMo notify
// ======================================================
router.post("/momo/callback", async (req, res) => {
  try {
    const data = req.body;
    console.log("MOMO CALLBACK:", data);

    const isValid = momoService.verifyCallback(data);
    if (!isValid) {
      console.error("Invalid callback signature");
      return res.status(400).json({ error: "Invalid signature" });
    }

    if (data.resultCode === 0) {
      // Tìm deposit và handle ngay
      const deposit = await DepositRequest.findOne({ momo_order_id: data.orderId });
      if (deposit) {
        await handlePaymentSuccess(data.orderId, deposit._id, "callback");
      }
    } else {
      // Fail: Update FAILED
      const deposit = await DepositRequest.findOne({ momo_order_id: data.orderId });
      if (deposit) {
        await DepositRequest.findByIdAndUpdate(deposit._id, {
          status: "FAILED",
          notes: data.message,
        });
      }
    }

    res.json({ resultCode: 0, message: "OK" }); // Luôn trả success cho MoMo
  } catch (err) {
    console.error("Callback error:", err);
    res.status(500).json({ error: "Callback failed" });
  }
});

// ======================================================
// 2) CHECK TRẠNG THÁI MOMO (manual cho user/admin)
// ======================================================
router.post(
  "/momo/check-status",
  [
    body("orderId")
      .notEmpty()
      .trim()
      .isString()
      .withMessage("OrderId must be a non-empty string"),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty())
      return res.status(400).json({ errors: errors.array() });

    try {
      const { orderId } = req.body;
      const status = await momoService.checkTransactionStatus(orderId);
      res.json({ success: true, momo_status: status });
    } catch (err) {
      console.error("Status check error:", err);
      res
        .status(500)
        .json({ error: "Failed to check momo status", details: err.message });
    }
  }
);

// ======================================================
// 7) USER LỊCH SỬ NẠP TIỀN
// ======================================================
router.get("/deposit/history", authMiddleware, async (req, res) => {
  try {
    const requests = await DepositRequest.find({ user_id: req.user.id }).sort({
      created_at: -1,
    });

    // Serialize to plain objects to avoid Decimal128 serialization issues
    const serialized = requests.map(r => ({
      ...r.toObject(),
      amount_vnd: Number(r.amount_vnd),
      amount_eth: String(r.amount_eth),
      exchange_rate: Number(r.exchange_rate)
    }));

    res.json({ deposit_requests: serialized });
  } catch (err) {
    console.error("Get deposit history error:", err);
    res.status(500).json({ error: "Failed to get history" });
  }
});


// ======================================================
// TEMP: GET BALANCE ON-CHAIN CỦA WALLET ADDRESS (public, cho test)
// ======================================================
router.get('/user/balance/:address', async (req, res) => {
  try {
    const { address } = req.params;

    // Validate address (optional, để an toàn)
    if (!ethers.utils.isAddress(address)) {
      return res.status(400).json({ error: 'Invalid Ethereum address' });
    }

    // Query balance từ provider (on-chain)
    const balanceWei = await provider.getBalance(address);
    const balanceEth = ethers.utils.formatEther(balanceWei);  // FIX: Thêm .utils cho v5

    // Optional: Convert sang VND (dùng utils - import nếu chưa có)
    const { weiToVnd, formatEth } = require('../utils/conversion');  // Import nếu chưa
    const balanceVnd = weiToVnd(balanceWei.toString());

    res.json({
      address: address.toLowerCase(),
      balance_eth: balanceEth,
      balance_wei: balanceWei.toString(),
      balance_vnd: balanceVnd,
      formatted_eth: formatEth(balanceWei.toString())  // Dùng utils để format đẹp
    });

    console.log(`Balance query for ${address}: ${balanceEth} ETH`);
  } catch (err) {
    console.error('Balance query error:', err);
    res.status(500).json({ error: 'Failed to fetch balance', details: err.message });
  }
});

// ======================================================
// 8) ADMIN GET TẤT CẢ REQUEST
// ======================================================
router.get("/admin/deposit-requests", authMiddleware, async (req, res) => {
  try {
    const admin = await User.findById(req.user.id);
    if (admin.role !== "ADMIN")
      return res.status(403).json({ error: "Admin access required" });

    const { status } = req.query;
    const query = status ? { status } : {};

    const requests = await DepositRequest.find(query)
      .populate("user_id", "username email wallet_address")
      .populate("approved_by", "username")
      .sort({ created_at: -1 });

    res.json({ deposit_requests: requests });
  } catch (err) {
    res.status(500).json({ error: "Failed to get all requests" });
  }
});

// ======================================================
// 9) USER TẠO YÊU CẦU RÚT TIỀN (ETH → VND)
// ======================================================
router.post(
  "/withdraw/request",
  authMiddleware,
  [
    body("amount_vnd").isFloat({ min: 50000, max: 100000000 }),
    body("bank_name").notEmpty(),
    body("account_number").notEmpty(),
    body("account_holder_name").notEmpty(),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty())
      return res.status(400).json({ errors: errors.array() });

    try {
      const { amount_vnd, bank_name, account_number, account_holder_name } = req.body;
      const userId = req.user.id;

      // 1. Get User & Check Balance
      const user = await User.findById(userId);
      if (!user) return res.status(404).json({ error: "User not found" });

      // Convert VND request to ETH
      const amountEthStr = vndToEth(amount_vnd);
      const amountWeiStr = toWei(amountEthStr);
      const amountWei = ethers.BigNumber.from(amountWeiStr).toBigInt();

      // Check user balance (stored as wei string in DB)
      const currentBalanceWei = BigInt(user.balance_eth || 0n);

      if (currentBalanceWei < amountWei) {
        return res.status(400).json({
          error: "Insufficient balance",
          details: `You need ${amountEthStr} ETH but have ${(Number(currentBalanceWei) / 1e18).toFixed(4)} ETH`
        });
      }

      // 2. Deduct Balance Immediately (Lock funds)
      const newBalanceWei = currentBalanceWei - amountWei;

      // Update User Balance
      await User.findByIdAndUpdate(userId, {
        balance_eth: newBalanceWei.toString()
      });

      // 3. Create Withdraw Request
      // Import WithdrawRequest model if not already imported at top, but assuming it is or will be.
      // Wait, I need to check if WithdrawRequest is imported.
      // Looking at file content, it is NOT imported. I need to add the import too.
      const WithdrawRequest = require("../models/WithdrawRequest");

      const withdrawRequest = await WithdrawRequest.create({
        user_id: userId,
        amount_vnd,
        amount_eth: amountEthStr,
        exchange_rate: EXCHANGE_RATE.ETH_TO_VND,
        bank_name,
        account_number,
        account_holder_name,
        status: "PENDING"
      });

      // 4. Log Transaction
      await Transaction.create({
        user_id: userId,
        type: TRANSACTION_TYPES.WITHDRAW,
        amount_vnd: amount_vnd,
        amount_eth: amountEthStr,
        status: "PENDING",
        exchange_rate: EXCHANGE_RATE.ETH_TO_VND,
        amount_eth_wei: amountWeiStr
      });

      res.json({
        success: true,
        message: "Withdraw request created successfully",
        withdraw_request: withdrawRequest,
        remaining_balance_eth: ethers.utils.formatEther(newBalanceWei)
      });

    } catch (err) {
      console.error("Create withdraw request error:", err);
      res.status(500).json({
        error: "Failed to create withdraw request",
        details: err.message
      });
    }
  }
);

// ======================================================
// 10) USER LỊCH SỬ RÚT TIỀN
// ======================================================
router.get("/withdraw/history", authMiddleware, async (req, res) => {
  try {
    const WithdrawRequest = require("../models/WithdrawRequest");
    const requests = await WithdrawRequest.find({ user_id: req.user.id }).sort({
      created_at: -1,
    });

    // Serialize to plain objects to avoid Decimal128 serialization issues
    const serialized = requests.map(r => ({
      ...r.toObject(),
      amount_vnd: Number(r.amount_vnd),
      amount_eth: String(r.amount_eth),
      exchange_rate: Number(r.exchange_rate)
    }));

    res.json({ withdraw_requests: serialized });
  } catch (err) {
    console.error("Get withdraw history error:", err);
    res.status(500).json({ error: "Failed to get withdraw history" });
  }
});

module.exports = router;