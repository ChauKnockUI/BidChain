const mongoose = require('mongoose');
const { ethers } = require('ethers');

const UserSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true, index: true },
  email: { type: String, required: true, unique: true, index: true },
  password_hash: { type: String, required: true },
  full_name: { type: String, required: true },
  role: {
    type: String,
    enum: ['ADMIN', 'MANAGER', 'USER'],
    required: true,
    default: 'USER'
  },
  status: {
    type: String,
    enum: ['ACTIVE', 'BANNED'],
    required: true,
    default: 'ACTIVE'
  },
  wallet_address: { type: String, required: true, unique: true },
  encrypted_private_key: { type: String, required: true },
  avatar: { type: String }, // Cloudinary URL from /upload/avatar

  // Address & Location fields
  country: { type: String },
  city: { type: String },
  district: { type: String },
  ward: { type: String },
  address: { type: String }, // Full address detail

  // Bio/Description
  bio: { type: String },

  // ĐÃ SỬA: DÙNG STRING + WEI (chuẩn blockchain)
  balance_eth: {
    type: String,
    default: "0",
    validate: {
      validator: v => /^\d+$/.test(v),
      message: "balance_eth must be a string of wei (integer)"
    }
  },
  locked_eth: {
    type: String,
    default: "0",
    validate: {
      validator: v => /^\d+$/.test(v),
      message: "locked_eth must be a string of wei (integer)"
    }
  },

  last_nonce: { type: Number, required: true, default: 0 },
  momo_phone: { type: String },
  created_at: { type: Date, default: Date.now }
});

// Virtual để hiển thị balance dưới dạng ETH (dùng trong API response)
UserSchema.virtual('balance_eth_formatted').get(function () {
  return ethers.utils.formatEther(this.balance_eth);
});

UserSchema.virtual('locked_eth_formatted').get(function () {
  return ethers.utils.formatEther(this.locked_eth);
});

module.exports = mongoose.model('User', UserSchema);