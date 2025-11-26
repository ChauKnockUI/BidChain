const mongoose = require('mongoose');

const AuctionSchema = new mongoose.Schema({
  seller_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  title: { type: String, required: true },
  description: { type: String, required: true },
  images: [{ type: String }],
  category_id: { type: mongoose.Schema.Types.ObjectId, required: true },
  status: {
    type: String,
    enum: ['PENDING_APPROVAL', 'APPROVED', 'REJECTED', 'DEPLOYING', 'ACTIVE', 'ENDED', 'SETTLED'],
    required: true,
    default: 'PENDING_APPROVAL'
  },
  rejection_reason: { type: String },
  approved_by: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  approved_at: { type: Date },
  contract_address: { type: String },
  deploy_tx_hash: { type: String },
  start_price: { type: mongoose.Decimal128, required: true }, // Wei
  step_price: { type: mongoose.Decimal128, required: true }, // Wei
  current_price: { type: mongoose.Decimal128, required: true }, // Wei
  highest_bidder_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  start_time: { type: Date, required:false },
  end_time: { type: Date, required: true, index: true }
}, { timestamps: true });

module.exports = mongoose.model('Auction', AuctionSchema);
