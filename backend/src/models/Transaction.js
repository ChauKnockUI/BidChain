const mongoose = require('mongoose');

const TransactionSchema = new mongoose.Schema({
  user_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  type: {
    type: String,
    enum: ['DEPOSIT', 'WITHDRAW', 'LISTING_FEE', 'AUCTION_SETTLEMENT'],
    required: true
  },
  amount_vnd: { type: mongoose.Decimal128 }, // Optional for some types
  amount_eth: { type: mongoose.Decimal128, required: true },
  exchange_rate: { type: mongoose.Decimal128, required: true },
  status: {
    type: String,
    enum: ['PENDING', 'COMPLETED', 'FAILED'],
    required: true,
    default: 'PENDING'
  },
  tx_hash: { type: String },
  momo_ref_id: { type: String },
  created_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Transaction', TransactionSchema);
