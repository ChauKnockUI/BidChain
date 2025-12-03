const mongoose = require('mongoose');

const NotificationSchema = new mongoose.Schema({
  user_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  type: {
    type: String,
    enum: ['AUCTION_APPROVED', 'AUCTION_PENDING_APPROVAL', 'AUCTION_REJECTED', 'OUTBID', 'WON_AUCTION', 'NEW_BID', 'AUCTION_SOLD', 'AUCTION_STARTED', 'DEPOSIT_SUCCESS', 'WITHDRAW_SUCCESS'],
    required: true
  },
  title: { type: String, required: true },
  message: { type: String, required: true },
  related_id: { type: mongoose.Schema.Types.ObjectId },
  is_read: { type: Boolean, required: true, default: false },
  created_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Notification', NotificationSchema);
