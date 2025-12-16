// src/utils/blockchain.js
// Utility functions for blockchain verification and auto-restore

const ethers = require('ethers');
const fs = require('fs');
const path = require('path');

/**
 * Verify a bid against blockchain and auto-restore if tampered
 * 
 * Safety checks:
 * 1. Bid must have on_chain_bid_hash (was recorded on-chain)
 * 2. Auction must have contract_address
 * 3. Matching event must exist on blockchain
 * 4. Only restore amount fields (not signature, user, etc.)
 * 
 * @param {Object} bid - Bid document (populated with auction_id)
 * @param {Object} options - { autoRestore: boolean, silent: boolean }
 * @returns {Object} { verified: boolean, tampered: boolean, restored: boolean, details: {} }
 */
async function verifyAndRestoreBid(bid, options = { autoRestore: true, silent: false }) {
    const result = {
        bid_id: bid._id?.toString(),
        verified: false,
        tampered: false,
        restored: false,
        skipped: false,
        error: null,
        details: {}
    };

    try {
        // Safety check 1: Bid must have on_chain_bid_hash
        if (!bid.on_chain_bid_hash) {
            result.skipped = true;
            result.details.reason = 'Bid không có on_chain_bid_hash - chưa được ghi on-chain';
            return result;
        }

        // Get auction from bid (handle both populated and non-populated)
        const auction = bid.auction_id;
        if (!auction) {
            result.skipped = true;
            result.details.reason = 'Không tìm thấy auction';
            return result;
        }

        // Safety check 2: Auction must have contract_address
        if (!auction.contract_address || !auction.blockchain_id) {
            result.skipped = true;
            result.details.reason = 'Auction không có contract_address hoặc blockchain_id';
            return result;
        }

        // Load contract
        const { provider } = require('../blockchain/contract');
        const abiPath = process.env.CONTRACT_ABI_PATH || './abi/Auction.json';
        const abiRaw = fs.readFileSync(path.resolve(abiPath), 'utf8');
        const abiParsed = JSON.parse(abiRaw);
        const abi = abiParsed.abi || abiParsed;

        const auctionContract = new ethers.Contract(auction.contract_address, abi, provider);

        // Query events from blockchain
        const filter = auctionContract.filters.BidRecorded(auction.blockchain_id);
        const events = await auctionContract.queryFilter(filter);

        // Safety check 3: Find matching event
        const matchingEvent = events.find(e =>
            e.args.bidHash.toLowerCase() === bid.on_chain_bid_hash.toLowerCase()
        );

        if (!matchingEvent) {
            result.skipped = true;
            result.details.reason = 'Không tìm thấy event matching trên blockchain';
            return result;
        }

        // Get original amount from blockchain
        const chainAmountWei = matchingEvent.args.amount.toString();
        const dbAmountWei = bid.amount_wei?.toString();

        result.details.chain_amount_wei = chainAmountWei;
        result.details.db_amount_wei = dbAmountWei;

        // Compare amounts
        if (chainAmountWei === dbAmountWei) {
            // Data is valid
            result.verified = true;
            result.details.status = 'VERIFIED';
            return result;
        }

        // TAMPERED DETECTED!
        result.tampered = true;
        result.details.status = 'TAMPERED';
        result.details.discrepancy = {
            db_value: dbAmountWei,
            chain_value: chainAmountWei,
            difference: (BigInt(dbAmountWei || '0') - BigInt(chainAmountWei)).toString()
        };

        if (!options.silent) {
            console.log(`🚨 TAMPERED BID DETECTED: ${bid._id}`);
            console.log(`   DB: ${dbAmountWei} wei`);
            console.log(`   Chain: ${chainAmountWei} wei`);
        }

        // Auto-restore if enabled
        if (options.autoRestore) {
            const Bid = require('../models/Bid');
            const { weiToVnd } = require('./conversion');

            const originalAmountVnd = weiToVnd(chainAmountWei);

            // Safety check 4: Only update amount fields
            await Bid.findByIdAndUpdate(bid._id, {
                amount_wei: chainAmountWei,
                amount_vnd: originalAmountVnd,
                restored_from_chain: true,
                restored_at: new Date(),
                // Note: restored_by is null for auto-restore
            });

            result.restored = true;
            result.details.restored_to = {
                amount_wei: chainAmountWei,
                amount_vnd: originalAmountVnd
            };

            if (!options.silent) {
                console.log(`🔄 AUTO-RESTORED bid ${bid._id}`);
                console.log(`   Restored to: ${originalAmountVnd} VND`);
            }
        }

        return result;

    } catch (error) {
        result.error = error.message;
        if (!options.silent) {
            console.error(`❌ Verify/restore error for bid ${bid._id}:`, error.message);
        }
        return result;
    }
}

/**
 * Verify and restore all bids for an auction
 * Also syncs Auction.current_price if winning bid was tampered
 * @param {string} auctionId - MongoDB auction ID
 * @param {Object} options - { autoRestore: boolean, silent: boolean }
 * @returns {Object} Summary of verification results
 */
async function verifyAndRestoreAuctionBids(auctionId, options = { autoRestore: true, silent: false }) {
    const Bid = require('../models/Bid');
    const Auction = require('../models/Auction');

    const auction = await Auction.findById(auctionId);
    if (!auction) {
        return { error: 'Auction not found' };
    }

    const bids = await Bid.find({ auction_id: auctionId }).populate('auction_id');

    const summary = {
        auction_id: auctionId,
        total_bids: bids.length,
        verified: 0,
        tampered: 0,
        restored: 0,
        skipped: 0,
        errors: 0,
        auction_synced: false,
        details: []
    };

    for (const bid of bids) {
        const result = await verifyAndRestoreBid(bid, options);

        if (result.verified) summary.verified++;
        if (result.tampered) summary.tampered++;
        if (result.restored) summary.restored++;
        if (result.skipped) summary.skipped++;
        if (result.error) summary.errors++;

        summary.details.push({
            bid_id: bid._id,
            status: result.details.status || (result.skipped ? 'SKIPPED' : 'ERROR'),
            restored: result.restored
        });
    }

    // SYNC AUCTION CURRENT_PRICE from winning bid
    // This ensures auction display is correct even if ONLY current_price was tampered
    // Changed: Always sync, not just when bids were restored
    if (options.autoRestore) {
        try {
            // Find the winning bid (highest valid bid)
            const winningBid = await Bid.findOne({
                auction_id: auctionId,
                status: 'WINNING'
            }).populate('user_id');

            if (winningBid) {
                const currentAuction = await Auction.findById(auctionId);

                // Check if auction current_price matches winning bid
                if (currentAuction.current_price?.toString() !== winningBid.amount_wei?.toString()) {
                    const { weiToVnd } = require('./conversion');
                    const correctPriceVnd = weiToVnd(winningBid.amount_wei);

                    await Auction.findByIdAndUpdate(auctionId, {
                        current_price: winningBid.amount_wei,
                        highest_bidder_id: winningBid.user_id?._id
                    });

                    summary.auction_synced = true;

                    if (!options.silent) {
                        console.log(`🔄 SYNCED Auction ${auctionId} current_price`);
                        console.log(`   Was: ${currentAuction.current_price} → Now: ${winningBid.amount_wei}`);
                        console.log(`   Display: ${correctPriceVnd} VND`);
                    }
                }
            }
        } catch (syncError) {
            if (!options.silent) {
                console.error(`❌ Failed to sync auction price:`, syncError.message);
            }
        }
    }

    if (!options.silent && summary.tampered > 0) {
        console.log(`📊 Auction ${auctionId} integrity check: ${summary.tampered} tampered, ${summary.restored} restored${summary.auction_synced ? ', auction synced' : ''}`);
    }

    return summary;
}

/**
 * Verify auction metadata (title, description, images) against blockchain hash
 * Auto-restores from original_metadata if tampered
 * @param {string} auctionId - MongoDB auction ID
 * @param {Object} options - { autoRestore: boolean, silent: boolean }
 * @returns {Object} { verified: boolean, tampered: boolean, restored: boolean }
 */
async function verifyAndRestoreMetadata(auctionId, options = { autoRestore: true, silent: false }) {
    const Auction = require('../models/Auction');
    const ethers = require('ethers');
    const fs = require('fs');
    const path = require('path');

    const result = {
        auction_id: auctionId,
        verified: false,
        tampered: false,
        restored: false,
        skipped: false,
        error: null
    };

    try {
        const auction = await Auction.findById(auctionId);
        if (!auction) {
            result.skipped = true;
            result.error = 'Auction not found';
            return result;
        }

        // Check if auction has metadata hash
        if (!auction.metadata_hash || !auction.contract_address || !auction.blockchain_id) {
            result.skipped = true;
            result.error = 'Auction không có metadata_hash hoặc blockchain info';
            return result;
        }

        // Check if original_metadata exists
        if (!auction.original_metadata || !auction.original_metadata.title) {
            result.skipped = true;
            result.error = 'Auction không có original_metadata';
            return result;
        }

        // Calculate current metadata hash
        const currentMetadataString = JSON.stringify({
            title: auction.title,
            description: auction.description,
            images: auction.images || []
        });
        const currentHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(currentMetadataString));

        // Get hash from blockchain
        const { provider } = require('../blockchain/contract');
        const abiPath = process.env.CONTRACT_ABI_PATH || './abi/Auction.json';
        const abiRaw = fs.readFileSync(path.resolve(abiPath), 'utf8');
        const abiParsed = JSON.parse(abiRaw);
        const abi = abiParsed.abi || abiParsed;

        const auctionContract = new ethers.Contract(auction.contract_address, abi, provider);
        const onChainHash = await auctionContract.getMetadataHash(auction.blockchain_id);

        // Compare hashes
        if (currentHash.toLowerCase() === onChainHash.toLowerCase()) {
            result.verified = true;
            return result;
        }

        // TAMPERED!
        result.tampered = true;

        if (!options.silent) {
            console.log(`🚨 METADATA TAMPERED: Auction ${auctionId}`);
            console.log(`   Current hash: ${currentHash}`);
            console.log(`   On-chain hash: ${onChainHash}`);
        }

        // Auto-restore if enabled
        if (options.autoRestore) {
            await Auction.findByIdAndUpdate(auctionId, {
                title: auction.original_metadata.title,
                description: auction.original_metadata.description,
                images: auction.original_metadata.images
            });

            result.restored = true;

            if (!options.silent) {
                console.log(`🔄 METADATA RESTORED for auction ${auctionId}`);
                console.log(`   Title: "${auction.original_metadata.title}"`);
            }
        }

        return result;

    } catch (error) {
        result.error = error.message;
        if (!options.silent) {
            console.error(`❌ Metadata verify error for ${auctionId}:`, error.message);
        }
        return result;
    }
}

module.exports = {
    verifyAndRestoreBid,
    verifyAndRestoreAuctionBids,
    verifyAndRestoreMetadata
};
