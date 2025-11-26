const mongoose = require('mongoose');

const BidSchema = new mongoose.Schema({
  auction_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Auction', required: true, index: true },
  user_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  amount_wei: { type: mongoose.Decimal128, required: true },
  signature: { type: String, required: true },
  nonce: { type: Number, required: true },
  status: {
    type: String,
    enum: ['VALID', 'INVALID', 'OUTBID', 'WINNING'],
    required: true,
    default: 'VALID'
  },
  created_at: { type: Date, default: Date.now },
  tx_settle_hash: { type: String }
}, { timestamps: true });

module.exports = mongoose.model('Bid', BidSchema);
