const mongoose = require('mongoose');

const BidSchema = new mongoose.Schema({
  auction_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Auction', required: true, index: true },
  user_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  amount_wei: { type: String, required: true }, // Changed to String for precision
  amount_vnd: { type: Number, required: true }, // For display
  signature: { type: String, required: true },
  nonce: { type: Number, required: true },
  timestamp: { type: Number, required: true }, // Unix timestamp when bid was signed
  verified_on_chain: { type: Boolean, default: false }, // Signature verified via smart contract
  status: {
    type: String,
    enum: ['VALID', 'INVALID', 'OUTBID', 'WINNING'],
    required: true,
    default: 'VALID'
  },
  created_at: { type: Date, default: Date.now },
  tx_settle_hash: { type: String } // Settlement transaction hash
}, { timestamps: true });

module.exports = mongoose.model('Bid', BidSchema);
