const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { ethers } = require('ethers');
const User = require('../models/User');
const { encrypt } = require('../utils/crypto');
require('dotenv').config();

const JWT_SECRET = process.env.JWT_SECRET || 'dev_secret';
const MASTER_KEY = process.env.MASTER_KEY;

/**
 * REGISTER
 * - tạo user
 * - tạo ví ETH (address + privateKey)
 * - mã hoá privateKey bằng AES-256-GCM
 * - lưu DB
 */
router.post('/register', async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password)
      return res.status(400).json({ error: 'Missing username or password' });

    const existing = await User.findOne({ username });
    if (existing)
      return res.status(400).json({ error: 'User already exists' });

    // Hash mật khẩu
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    // Tạo ví ETH
    const wallet = ethers.Wallet.createRandom();

    // Mã hoá privateKey trước khi lưu
    const encryptedPrivateKey = encrypt(wallet.privateKey, MASTER_KEY);

    // Lưu DB
    const user = new User({
      username,
      passwordHash,
      ethAddress: wallet.address,
      encryptedPrivateKey
    });

    await user.save();

    // Tạo JWT
    const token = jwt.sign(
      { id: user._id, username: user.username },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      token,
      username: user.username,
      ethAddress: user.ethAddress
    });

  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});


/**
 * LOGIN
 * - kiểm tra username/password
 * - trả token + ethAddress
 */
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    const user = await User.findOne({ username });
    if (!user)
      return res.status(400).json({ error: 'Invalid username or password' });

    const ok = await bcrypt.compare(password, user.passwordHash);
    if (!ok)
      return res.status(400).json({ error: 'Invalid username or password' });

    // Tạo token
    const token = jwt.sign(
      { id: user._id, username: user.username },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      token,
      username: user.username,
      ethAddress: user.ethAddress
    });

  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;