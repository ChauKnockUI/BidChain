const mongoose = require('mongoose');

const DepositRequestSchema = new mongoose.Schema({
  user_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  amount_vnd: { type: Number, required: true },
  amount_eth: { type: String, required: true },
  exchange_rate: { type: Number, required: true },

  // Momo payment details
  momo_order_id: { type: String, required: true, unique: true },
  momo_qr_code: { type: String },
  momo_qr_url: { type: String },

  // Status flow: PENDING_PAYMENT → PAID → APPROVED → COMPLETED → FAILED
  status: {
    type: String,
    enum: ['PENDING_PAYMENT', 'PAID', 'APPROVED', 'COMPLETED', 'FAILED', 'REJECTED'],
    required: true,
    default: 'PENDING_PAYMENT'
  },

  // Timestamps
  created_at: { type: Date, default: Date.now },
  paid_at: { type: Date },
  approved_at: { type: Date },
  completed_at: { type: Date },

  // Admin actions
  approved_by: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  rejection_reason: { type: String },

  // Blockchain
  funding_tx_hash: { type: String }, // ETH transfer tx hash

  // Additional metadata
  user_ip: { type: String },
  user_agent: { type: String },
  notes: { type: String }
});

module.exports = mongoose.model('DepositRequest', DepositRequestSchema);
