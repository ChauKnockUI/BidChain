// routes/auth.js
const express = require("express");
const router = express.Router();
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const { ethers } = require("ethers");
const User = require("../models/User");
const { encrypt } = require("../utils/crypto");
const { validateRegister } = require("../middleware/auth");

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
  const { username, password } = req.body;

  try {
    const existing = await User.findOne({ username });
    if (existing) {
      return res.status(400).json({ error: "User already exists" });
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    const wallet = ethers.Wallet.createRandom();
    const encryptedPrivateKey = encrypt(wallet.privateKey, MASTER_KEY);

    const user = new User({
      username,
      passwordHash,
      ethAddress: wallet.address,
      encryptedPrivateKey,
    });

    await user.save();

    const token = jwt.sign(
      { id: user._id, username: user.username },
      JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.json({
      token,
      username: user.username,
      ethAddress: user.ethAddress,
    });
  } catch (e) {
    console.error("Register error:", e.message);
    res.status(500).json({ error: "Internal server error" });
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

    const isMatch = await bcrypt.compare(password, user.passwordHash);
    if (!isMatch) {
      return res.status(400).json({ error: "Invalid credentials" });
    }

    const token = jwt.sign(
      { id: user._id, username: user.username },
      JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.json({
      token,
      username: user.username,
      ethAddress: user.ethAddress,
    });
  } catch (e) {
    console.error("Login error:", e.message);
    res.status(500).json({ error: "Internal server error" });
  }
});

module.exports = router;