// routes/auth.js
const express = require("express");
const router = express.Router();
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const { ethers } = require("ethers");
const User = require("../models/User");
const { encrypt } = require("../utils/crypto");
const { validateRegister, authMiddleware } = require("../middleware/auth");
const { walletFromPrivateKey, provider } = require("../blockchain/contract");
const { ethToVnd, formatVnd, toWei, weiToEth } = require("../utils/conversion");
const { EXCHANGE_RATE } = require("../config/constants");

const JWT_SECRET = process.env.JWT_SECRET || "dev_secret";
const MASTER_KEY = process.env.MASTER_KEY;

// === KIỂM TRA MASTER_KEY ===
if (!MASTER_KEY || MASTER_KEY.length !== 64 || !/^[0-9a-fA-F]{64}$/.test(MASTER_KEY)) {
  console.error("LỖI: MASTER_KEY phải là chuỗi hex 64 ký tự (32 bytes).");
  process.exit(1);
}

/**
 * REGISTER
 */
router.post("/register", validateRegister, async (req, res) => {
  const {
    username,
    password,
    email,
    full_name,
    role = "USER", // mặc định là bidder nếu không gửi
    momo_phone
  } = req.body;

  try {
    // Kiểm tra username hoặc email đã tồn tại chưa
    const existingUser = await User.findOne({
      $or: [{ username }, { email }]
    });
    if (existingUser) {
      return res.status(400).json({ error: "Username hoặc email đã được sử dụng" });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(password, salt);

    // Tạo ví Ethereum
    const wallet = ethers.Wallet.createRandom();
    const encrypted_private_key = encrypt(wallet.privateKey, MASTER_KEY); // hàm encrypt của bạn

    // Tạo user mới với đầy đủ field bắt buộc
    const user = new User({
      username: username.trim(),
      email: email.toLowerCase().trim(),
      password_hash,
      full_name: full_name.trim(),
      role: role.toUpperCase(), // đảm bảo viết hoa
      status: 'ACTIVE',
      wallet_address: wallet.address,
      encrypted_private_key,
      balance_eth: "0", // Decimal128 phải là string hoặc Decimal128 object
      locked_eth: "0",
      last_nonce: 0,
      momo_phone
    });

    await user.save();

    // Tạo JWT
    const token = jwt.sign(
      { id: user._id, role: user.role },
      JWT_SECRET,
      { expiresIn: "7d" }
    );

    return res.status(201).json({
      message: "Đăng ký thành công",
      token,
      user: {
        username: user.username || username,
        email: user.email,
        full_name: user.full_name,
        role: user.role,
        wallet_address: user.wallet_address,
        balance_eth: weiToEth(user.balance_eth || "0"),
        locked_eth: weiToEth(user.locked_eth || "0"),
        avatar: user.avatar,
        momo_phone: user.momo_phone,
        country: user.country,
        city: user.city,
        district: user.district,
        ward: user.ward,
        address: user.address,
        bio: user.bio
      }
    });

  } catch (err) {
    console.error("Register error:", err);
    if (err.name === 'ValidationError') {
      const errors = Object.values(err.errors).map(e => e.message);
      return res.status(400).json({ error: "Dữ liệu không hợp lệ", details: errors });
    }
    if (err.code === 11000) {
      return res.status(400).json({ error: "Email hoặc wallet đã được sử dụng" });
    }
    res.status(500).json({ error: "Lỗi server" });
  }
});

/**
 * LOGIN
 */
router.post("/login", async (req, res) => {
  try {
    const { username, password } = req.body;
    if (!username || !password) {
      return res.status(400).json({ error: "Missing username or password" });
    }

    const user = await User.findOne({ username });
    if (!user) {
      return res.status(400).json({ error: "Invalid credentials" });
    }

    const isMatch = await bcrypt.compare(password, user.password_hash);

    if (!isMatch) {
      return res.status(400).json({ error: "Invalid credentials" });
    }

    const token = jwt.sign(
      { id: user._id, username: user.username || username, role: user.role },
      JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.json({
      token,
      id: user._id,
      username: user.username || username,
      email: user.email,
      full_name: user.full_name,
      wallet_address: user.wallet_address,
      balance_eth: weiToEth(user.balance_eth || "0"),
      locked_eth: weiToEth(user.locked_eth || "0"),
      avatar: user.avatar,
      momo_phone: user.momo_phone,
      country: user.country,
      city: user.city,
      district: user.district,
      ward: user.ward,
      address: user.address,
      bio: user.bio
    });

  } catch (err) {
    console.error("Login error:", err);
    res.status(500).json({ error: "Lỗi server" });
  }
});

/**
 * CHANGE PASSWORD
 */
router.put("/change-password", authMiddleware, async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return res.status(400).json({ error: "Vui lòng nhập đầy đủ mật khẩu hiện tại và mật khẩu mới" });
    }

    if (newPassword.length < 8) {
      return res.status(400).json({ error: "Mật khẩu mới phải có ít nhất 8 ký tự" });
    }

    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    // Verify current password
    const isMatch = await bcrypt.compare(currentPassword, user.password_hash);
    if (!isMatch) {
      return res.status(400).json({ error: "Mật khẩu hiện tại không chính xác" });
    }

    // Check if new password is same as current
    const isSamePassword = await bcrypt.compare(newPassword, user.password_hash);
    if (isSamePassword) {
      return res.status(400).json({ error: "Mật khẩu mới phải khác mật khẩu hiện tại" });
    }

    // Hash new password
    const salt = await bcrypt.genSalt(10);
    const newPasswordHash = await bcrypt.hash(newPassword, salt);

    // Update password
    user.password_hash = newPasswordHash;
    await user.save();

    res.json({ message: "Password changed successfully" });

  } catch (err) {
    console.error("Change password error:", err);
    res.status(500).json({ error: "Lỗi server" });
  }
});

/**
 * ADMIN FUND WALLET
 */
router.post("/admin/fund-wallet", authMiddleware, async (req, res) => {
  try {
    const { user_id, amount_eth } = req.body;

    // Check if requester is admin (simplified check - in production use proper role checking)
    const requester = await User.findById(req.user.id);
    if (requester.role !== 'ADMIN') {
      return res.status(403).json({ error: 'Admin access required' });
    }

    const targetUser = await User.findById(user_id);
    if (!targetUser) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Get admin wallet
    const adminWallet = walletFromPrivateKey(process.env.ADMIN_PRIVATE_KEY);

    // Check admin balance
    const adminBalance = await provider.getBalance(adminWallet.address);
    const amountWei = ethers.utils.parseEther(amount_eth);

    if (adminBalance.lt(amountWei)) {
      return res.status(400).json({
        error: 'Insufficient admin balance',
        required: amount_eth + ' ETH',
        available: ethers.utils.formatEther(adminBalance) + ' ETH'
      });
    }

    // Transfer ETH from admin to user
    const tx = await adminWallet.sendTransaction({
      to: targetUser.wallet_address,
      value: amountWei
    });

    const receipt = await tx.wait();

    // Update user balance in database - manual calculation for string-based balance
    const currentBalance = ethers.BigNumber.from(targetUser.balance_eth || "0");
    const amountToAdd = ethers.BigNumber.from(toWei(amount_eth));
    const newBalance = currentBalance.add(amountToAdd).toString();

    await User.findByIdAndUpdate(targetUser._id, {
      $set: { balance_eth: newBalance }
    });

    // Create transaction record
    const { Transaction } = require('../models/Transaction');
    await Transaction.create({
      user_id: targetUser._id,
      type: 'ADMIN_FUNDING',
      amount_eth: parseFloat(amount_eth),
      exchange_rate: EXCHANGE_RATE.ETH_TO_VND,
      status: 'COMPLETED',
      tx_hash: receipt.transactionHash
    });

    res.json({
      success: true,
      message: `Funded ${targetUser.username} with ${amount_eth} ETH`,
      tx_hash: receipt.transactionHash,
      new_balance: parseFloat(targetUser.balance_eth) + parseFloat(amount_eth)
    });

  } catch (error) {
    console.error('Fund wallet error:', error);
    res.status(500).json({ error: 'Failed to fund wallet' });
  }
});

/**
 * GET WALLET BALANCE (Blockchain)
 * Check actual ETH balance in user's wallet
 */
router.get("/wallet/balance-blockchain/:userId", authMiddleware, async (req, res) => {
  try {
    const targetUser = await User.findById(req.params.userId);
    if (!targetUser) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Get actual blockchain balance
    const blockchainBalance = await provider.getBalance(targetUser.wallet_address);
    const blockchainBalanceEth = parseFloat(ethers.utils.formatEther(blockchainBalance));

    res.json({
      user_id: targetUser._id,
      username: targetUser.username,
      wallet_address: targetUser.wallet_address,
      blockchain_balance_eth: blockchainBalanceEth,
      blockchain_balance_vnd: ethToVnd(blockchainBalanceEth),
      formatted_blockchain_balance: formatVnd(ethToVnd(blockchainBalanceEth))
    });

  } catch (error) {
    console.error('Get blockchain balance error:', error);
    res.status(500).json({ error: 'Failed to get blockchain balance' });
  }
});

/**
 * DEMO: FUND ALL USERS WITH ETH
 * For demo purposes - funds all registered users with 10 ETH each
 */
router.post("/demo/fund-all-users", async (req, res) => {
  try {
    // Only allow in development
    if (process.env.NODE_ENV === 'production') {
      return res.status(403).json({ error: 'Not available in production' });
    }

    const users = await User.find({}).limit(15); // Fund max 10 users for demo
    const adminWallet = walletFromPrivateKey(process.env.DEPLOYER_PRIVATE_KEY);

    const results = [];

    for (const user of users) {
      try {
        const amountEth = "1.0"; // 10 ETH each
        const amountWei = ethers.utils.parseEther(amountEth);

        // Check admin balance
        const adminBalance = await provider.getBalance(adminWallet.address);
        if (adminBalance.lt(amountWei)) {
          results.push({
            username: user.username,
            status: 'failed',
            error: 'Insufficient admin balance'
          });
          continue;
        }

        // Transfer ETH
        const tx = await adminWallet.sendTransaction({
          to: user.wallet_address,
          value: amountWei
        });

        const receipt = await tx.wait();

        // Update database - manual calculation for string-based balance
        const currentBalance = ethers.BigNumber.from(user.balance_eth || "0");
        const amountToAdd = ethers.BigNumber.from(toWei(amountEth));
        const newBalance = currentBalance.add(amountToAdd).toString();

        await User.findByIdAndUpdate(user._id, {
          $set: { balance_eth: newBalance }
        });

        results.push({
          username: user.username,
          status: 'success',
          amount_eth: amountEth,
          tx_hash: receipt.transactionHash
        });

        // Small delay to avoid nonce issues
        await new Promise(resolve => setTimeout(resolve, 1000));

      } catch (error) {
        results.push({
          username: user.username,
          status: 'failed',
          error: error.message
        });
      }
    }

    res.json({
      success: true,
      message: `Funded ${results.filter(r => r.status === 'success').length}/${users.length} users`,
      results
    });

  } catch (error) {
    console.error('Fund all users error:', error);
    res.status(500).json({ error: 'Failed to fund users' });
  }
});

module.exports = router;