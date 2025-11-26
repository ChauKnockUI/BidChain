const mongoose = require('mongoose');

const AuditLogSchema = new mongoose.Schema({
  actor_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  action: {
    type: String,
    enum: ['APPROVE_AUCTION', 'REJECT_AUCTION', 'BAN_USER', 'DEPLOY_CONTRACT', 'MANUAL_REFUND'],
    required: true
  },
  target_id: { type: mongoose.Schema.Types.ObjectId, required: true },
  details: { type: Object },
  ip_address: { type: String },
  created_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model('AuditLog', AuditLogSchema);
