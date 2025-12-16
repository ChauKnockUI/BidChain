const mongoose = require('mongoose');

const AuctionSchema = new mongoose.Schema({
  seller_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  title: { type: String, required: true },
  description: { type: String, required: true },
  images: [{ type: String }],
  category_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Category', required: true },
  status: {
    type: String,
    enum: ['PENDING_APPROVAL', 'APPROVED', 'REJECTED', 'DEPLOYING', 'ACTIVE', 'ENDED', 'WAITING_CONFIRMATION', 'SETTLED'],
    required: true,
    default: 'PENDING_APPROVAL'
  },
  rejection_reason: { type: String },
  approved_by: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  approved_at: { type: Date },
  contract_address: { type: String },
  deploy_tx_hash: { type: String },

  // PHẢI DÙNG STRING WEI - KHÔNG DÙNG Decimal128 NỮA!
  start_price: {
    type: String,
    required: true,
    validate: {
      validator: v => /^\d+$/.test(v),
      message: "start_price must be a string of wei (integer)"
    }
  },
  step_price: {
    type: String,
    required: true,
    validate: {
      validator: v => /^\d+$/.test(v),
      message: "step_price must be a string of wei (integer)"
    }
  },
  current_price: {
    type: String,
    required: true,
    default: "0",
    validate: {
      validator: v => /^\d+$/.test(v),
      message: "current_price must be a string of wei (integer)"
    }
  },

  highest_bidder_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  start_time: { type: Date },
  end_time: { type: Date, required: true, index: true },

  // Blockchain tracking
  blockchain_id: { type: Number }, // On-chain auction ID from smart contract
  settled_on_chain: { type: Boolean, default: false }, // Whether settlement happened on blockchain
  settlement_tx: { type: String }, // Settlement transaction hash

  // Metadata protection (title, images, description)
  original_metadata: {
    title: { type: String },
    description: { type: String },
    images: [{ type: String }]
  },
  metadata_hash: { type: String },    // Hash stored on-chain
  metadata_hash_tx: { type: String }  // TX hash when metadata hash was set
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtuals để hiển thị đẹp trong API
AuctionSchema.virtual('start_price_vnd').get(function () {
  const { weiToVnd } = require('../utils/conversion');
  return weiToVnd(this.start_price);
});

AuctionSchema.virtual('step_price_vnd').get(function () {
  const { weiToVnd } = require('../utils/conversion');
  return weiToVnd(this.step_price);
});

AuctionSchema.virtual('current_price_vnd').get(function () {
  const { weiToVnd } = require('../utils/conversion');
  return weiToVnd(this.current_price);
});

module.exports = mongoose.model('Auction', AuctionSchema);