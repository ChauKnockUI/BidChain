// src/cron/settlement.js
const Auction = require('../models/Auction');
const Bid = require('../models/Bid');
const User = require('../models/User');
const Notification = require('../models/Notification');
const { contract, walletFromPrivateKey } = require('../blockchain/contract');
const { weiToVnd, formatVnd } = require('../utils/conversion');
const { AUCTION_STATUS } = require('../config/constants');
require('dotenv').config();

/**
 * Settle auction on blockchain and finalize balances
 */
async function settleAuctionOnChain(auction) {
    try {
        console.log(`\n========== Settling Auction ${auction._id} ==========`);

        // Check if auction has bids
        if (!auction.highest_bidder_id) {
            console.log(`No bids on auction ${auction._id}, marking as ENDED`);
            await Auction.findByIdAndUpdate(auction._id, {
                status: AUCTION_STATUS.ENDED,
                settled_on_chain: true
            });
            return;
        }

        // Get winning bid with signature
        const winningBid = await Bid.findOne({
            auction_id: auction._id,
            status: 'WINNING'
        }).populate('user_id');

        if (!winningBid) {
            console.error(`No winning bid found for auction ${auction._id}`);
            return;
        }

        console.log(`Winner: ${winningBid.user_id.full_name} (${winningBid.user_id.wallet_address})`);
        console.log(`Final price: ${formatVnd(winningBid.amount_vnd)}`);

        // Get seller
        const seller = await User.findById(auction.seller_id);
        if (!seller) {
            console.error(`Seller not found for auction ${auction._id}`);
            return;
        }

        // Call smart contract settlement using AUCTION'S contract_address
        if (auction.blockchain_id && auction.contract_address) {
            console.log(`Calling smart contract settlement for blockchain ID ${auction.blockchain_id}`);
            console.log(`   Contract: ${auction.contract_address}`);

            const deployer = walletFromPrivateKey(process.env.DEPLOYER_PRIVATE_KEY);

            try {
                // Load ABI and create contract instance using AUCTION'S contract_address
                const fs = require('fs');
                const path = require('path');
                const ethers = require('ethers');
                const { provider } = require('../blockchain/contract');

                const abiPath = process.env.CONTRACT_ABI_PATH || './abi/Auction.json';
                const abiRaw = fs.readFileSync(path.resolve(abiPath), 'utf8');
                const abiParsed = JSON.parse(abiRaw);
                const abi = abiParsed.abi || abiParsed;

                const auctionContract = new ethers.Contract(auction.contract_address, abi, provider);

                const tx = await auctionContract.connect(deployer).settleAuction(
                    auction.blockchain_id,
                    winningBid.user_id.wallet_address,
                    winningBid.amount_wei
                );

                console.log(`Settlement transaction sent: ${tx.hash}`);
                const receipt = await tx.wait();
                console.log(`Settlement confirmed in block ${receipt.blockNumber}`);

                // Update auction with settlement info
                await Auction.findByIdAndUpdate(auction._id, {
                    status: AUCTION_STATUS.WAITING_CONFIRMATION,
                    settled_on_chain: true,
                    settlement_tx: tx.hash
                });

            } catch (error) {
                console.error(`❌ Failed to settle auction ${auction._id}:`, error);
            }
        } else {
            // Nếu không có blockchain_id vẫn update status
            await Auction.findByIdAndUpdate(auction._id, {
                status: AUCTION_STATUS.WAITING_CONFIRMATION,
                settled_on_chain: true
            });
        }

        // === Finalize balances (off-chain) ===

        // 1. Unlock winner's locked funds and deduct from balance
        const winnerLockedBigInt = BigInt(winningBid.user_id.locked_eth || "0");
        const bidAmountBigInt = BigInt(winningBid.amount_wei);
        const winnerBalanceBigInt = BigInt(winningBid.user_id.balance_eth || "0");

        console.log(`DEBUG: User ${winningBid.user_id._id}`);
        console.log(`DEBUG: Pre-settlement Locked: ${winnerLockedBigInt.toString()}`);
        console.log(`DEBUG: Pre-settlement Balance: ${winnerBalanceBigInt.toString()}`);
        console.log(`DEBUG: Bid Amount: ${bidAmountBigInt.toString()}`);

        const newWinnerLocked = (winnerLockedBigInt - bidAmountBigInt).toString();
        const newWinnerBalance = (winnerBalanceBigInt - bidAmountBigInt).toString();

        console.log(`DEBUG: New Locked: ${newWinnerLocked}`);
        console.log(`DEBUG: New Balance: ${newWinnerBalance}`);

        await User.findByIdAndUpdate(winningBid.user_id._id, {
            $set: {
                locked_eth: newWinnerLocked >= 0 ? newWinnerLocked : "0",
                balance_eth: newWinnerBalance >= 0 ? newWinnerBalance : "0"
            }
        });

        console.log(`Winner balance updated: -${formatVnd(winningBid.amount_vnd)}`);

        // 2. Add funds to seller's balance -> REMOVED for Escrow
        console.log(`Funds held in escrow for seller: ${formatVnd(winningBid.amount_vnd)}`);

        // 3. Create notifications
        await Notification.create({
            user_id: winningBid.user_id._id,
            type: 'WON_AUCTION',
            title: 'Chúc mừng! Bạn đã thắng đấu giá',
            message: `Bạn đã thắng phiên đấu giá "${auction.title}" với giá ${formatVnd(winningBid.amount_vnd)}`,
            related_id: auction._id
        });

        await Notification.create({
            user_id: seller._id,
            type: 'AUCTION_SOLD',
            title: 'Phiên đấu giá đã kết thúc',
            message: `Phiên đấu giá "${auction.title}" đã kết thúc. Vui lòng giao hàng để nhận tiền.`,
            related_id: auction._id
        });

        // Emit Socket.IO events
        const io = global.io;
        if (io) {
            io.to(`user_${winningBid.user_id._id}`).emit('auction_won', {
                auction_id: auction._id,
                title: auction.title,
                final_price_vnd: winningBid.amount_vnd,
                formatted_final_price: formatVnd(winningBid.amount_vnd)
            });

            io.to(`user_${seller._id}`).emit('auction_sold', {
                auction_id: auction._id,
                title: auction.title,
                final_price_vnd: winningBid.amount_vnd,
                formatted_final_price: formatVnd(winningBid.amount_vnd)
            });
        }

        console.log(`✅ Auction ${auction._id} settled successfully\n`);

    } catch (error) {
        console.error(`❌ Error settling auction ${auction._id}:`, error);
    }
}

async function runSettlementCron() {
    try {
        const now = new Date();
        // Find auctions that ended but not yet settled
        const endedAuctions = await Auction.find({
            status: { $in: [AUCTION_STATUS.ACTIVE, AUCTION_STATUS.ENDED] },
            end_time: { $lt: now },
            settled_on_chain: false
        }).populate('seller_id highest_bidder_id');

        if (endedAuctions.length > 0) {
            console.log(`\n📦 Found ${endedAuctions.length} auction(s) to settle`);
            for (const auction of endedAuctions) {
                await settleAuctionOnChain(auction);
            }
        }
    } catch (error) {
        console.error('Settlement cron error:', error);
    }
}


// Export for use in app.js
module.exports = { runSettlementCron, settleAuctionOnChain };
