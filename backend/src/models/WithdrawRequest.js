const mongoose = require('mongoose');

const WithdrawRequestSchema = new mongoose.Schema({
    user_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    amount_vnd: { type: Number, required: true },
    amount_eth: { type: String, required: true },
    exchange_rate: { type: Number, required: true },

    // Bank Information
    bank_name: { type: String, required: true },
    account_number: { type: String, required: true },
    account_holder_name: { type: String, required: true },

    // Status flow: PENDING → APPROVED → COMPLETED (Money sent) → FAILED / REJECTED
    status: {
        type: String,
        enum: ['PENDING', 'APPROVED', 'COMPLETED', 'FAILED', 'REJECTED'],
        required: true,
        default: 'PENDING'
    },

    // Timestamps
    created_at: { type: Date, default: Date.now },
    processed_at: { type: Date },

    // Admin actions
    processed_by: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    rejection_reason: { type: String },

    // Transaction reference (if any, e.g. bank ref)
    bank_tx_ref: { type: String },

    notes: { type: String }
});

module.exports = mongoose.model('WithdrawRequest', WithdrawRequestSchema);
