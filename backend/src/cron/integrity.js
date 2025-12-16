// src/cron/integrity.js
// Cron job for automatic bid integrity verification and restoration

const Auction = require('../models/Auction');
const { verifyAndRestoreAuctionBids } = require('../utils/blockchain');
const { AUCTION_STATUS } = require('../config/constants');

/**
 * Run integrity check on active auctions
 * Checks all bids, auto-restores any tampered data
 */
async function runIntegrityCheck() {
    try {
        console.log('\n🔍 Running bid integrity check...');

        // Find all auctions with blockchain integration
        const auctions = await Auction.find({
            blockchain_id: { $exists: true, $ne: null },
            contract_address: { $exists: true, $ne: null },
            status: {
                $in: [
                    AUCTION_STATUS.ACTIVE,
                    AUCTION_STATUS.APPROVED,
                    AUCTION_STATUS.WAITING_CONFIRMATION
                ]
            }
        });

        if (auctions.length === 0) {
            console.log('ℹ️ No active blockchain auctions found');
            return;
        }

        console.log(`📦 Checking ${auctions.length} auction(s)...`);

        let totalTampered = 0;
        let totalRestored = 0;

        for (const auction of auctions) {
            const result = await verifyAndRestoreAuctionBids(auction._id.toString(), {
                autoRestore: true,
                silent: true  // Don't log each bid, only summary
            });

            if (result.tampered > 0) {
                console.log(`🚨 Auction "${auction.title}": ${result.tampered} tampered bid(s), ${result.restored} restored`);
                totalTampered += result.tampered;
                totalRestored += result.restored;
            }
        }

        if (totalTampered > 0) {
            console.log(`\n📊 Integrity check complete: ${totalTampered} tampered, ${totalRestored} restored`);
        } else {
            console.log('✅ Integrity check complete: All bids verified');
        }

    } catch (error) {
        console.error('❌ Integrity check failed:', error.message);
    }
}

/**
 * Start the integrity cron job using setInterval
 * Runs every 5 minutes (300000 ms)
 */
function startIntegrityCron() {
    // Run every 5 minutes
    setInterval(runIntegrityCheck, 5 * 60 * 1000);

    console.log('🔄 Integrity cron job started (every 5 minutes)');

    // Also run immediately on startup after 10 seconds
    setTimeout(() => {
        runIntegrityCheck();
    }, 10000);
}

module.exports = { runIntegrityCheck, startIntegrityCron };
