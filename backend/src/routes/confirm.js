const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth');
const Auction = require('../models/Auction');
const User = require('../models/User');
const Notification = require('../models/Notification');
const { contract, walletFromPrivateKey } = require('../blockchain/contract');
const { AUCTION_STATUS } = require('../config/constants');
const { formatVnd } = require('../utils/conversion');
const { ethers } = require('ethers');
const { decrypt } = require('../utils/crypto');

// POST /api/confirm/:id
router.post('/:id', authMiddleware, async (req, res) => {
    try {
        console.log('🟢 CONFIRM ROUTE HIT!');
        console.log('🟢 Request params:', req.params);
        console.log('🟢 Request user:', req.user);

        const auctionId = req.params.id;
        const userId = req.user.id;

        console.log(`🟢 Processing confirmation for auction ${auctionId} by user ${userId}`);

        const auction = await Auction.findById(auctionId).populate('seller_id');
        if (!auction) {
            return res.status(404).json({ error: 'Auction not found' });
        }

        // Check if user is the winner
        if (auction.highest_bidder_id.toString() !== userId) {
            return res.status(403).json({ error: 'Only the winner can confirm receipt' });
        }

        // Check status
        if (auction.status !== AUCTION_STATUS.WAITING_CONFIRMATION) {
            return res.status(400).json({ error: 'Auction is not waiting for confirmation' });
        }

        // Blockchain confirmation (Best effort)
        if (auction.blockchain_id) {
            try {
                console.log(`Attempting blockchain confirmation for ID ${auction.blockchain_id}`);

                const userWithKey = await User.findById(userId).select('+encrypted_private_key');
                if (!userWithKey || !userWithKey.encrypted_private_key) {
                    throw new Error('User wallet/key not found');
                }

                console.log('DEBUG: Decrypting key...');
                const privateKey = decrypt(userWithKey.encrypted_private_key, process.env.MASTER_KEY);
                const userWallet = walletFromPrivateKey(privateKey);

                const tx = await contract.connect(userWallet).confirmReceived(auction.blockchain_id);
                console.log(`Confirm transaction sent: ${tx.hash}`);
                const receipt = await tx.wait();
                console.log(`Confirm confirmed in block ${receipt.blockNumber}`);
            } catch (error) {
                console.error('⚠️ Blockchain confirmation failed (continuing off-chain):', error.message);
                // Continue execution - do not fail the request
            }
        }

        // Update Seller Balance - Now using ON-CHAIN settlement
        // The BidChainWallet contract transfers from winner's locked balance to seller
        const winningBid = await require('../models/Bid').findOne({
            auction_id: auction._id,
            status: 'WINNING'
        });

        if (winningBid) {
            const bidAmountWei = winningBid.amount_wei.toString();
            const winner = await User.findById(auction.highest_bidder_id);
            const seller = await User.findById(auction.seller_id._id);

            // ========== ON-CHAIN SETTLEMENT ==========
            let settlementTxHash = null;
            try {
                const { settleBid, isWalletContractAvailable } = require('../blockchain/wallet-contract');

                if (isWalletContractAvailable() && auction.blockchain_id && winner?.wallet_address && seller?.wallet_address) {
                    console.log(`💸 Settling on-chain: ${bidAmountWei} wei from ${winner.wallet_address} to ${seller.wallet_address}...`);
                    const result = await settleBid(
                        winner.wallet_address,
                        seller.wallet_address,
                        auction.blockchain_id,
                        bidAmountWei
                    );
                    settlementTxHash = result.txHash;
                    console.log(`✅ On-chain settlement successful! TX: ${settlementTxHash}`);
                }
            } catch (settleError) {
                console.error('⚠️ On-chain settlement failed:', settleError.message);
                // Fall back to off-chain DB update
            }

            // Update MongoDB as cache (off-chain fallback and for display)
            const sellerBalanceBigInt = BigInt(seller.balance_eth || "0");
            const newSellerBalance = (sellerBalanceBigInt + BigInt(bidAmountWei)).toString();

            await User.findByIdAndUpdate(seller._id, {
                $set: { balance_eth: newSellerBalance }
            });
            console.log(`Seller balance updated (cache): +${formatVnd(winningBid.amount_vnd)}`);
        }

        // Update Auction Status
        console.log(`Updating auction ${auction._id} status to SETTLED`);
        const updatedAuction = await Auction.findByIdAndUpdate(auction._id, {
            status: AUCTION_STATUS.SETTLED,
            settled_on_chain: true
        }, { new: true });

        if (!updatedAuction) {
            console.error(`Failed to update auction ${auction._id} status`);
        } else {
            console.log(`Auction status updated to: ${updatedAuction.status}`);
        }

        // Notify Seller
        await Notification.create({
            user_id: auction.seller_id._id,
            type: 'AUCTION_SOLD',
            title: 'Người mua đã xác nhận nhận hàng',
            message: `Người mua đã xác nhận nhận hàng cho phiên đấu giá "${auction.title}". Tiền đã được chuyển vào ví của bạn.`,
            related_id: auction._id
        });

        // Notify Winner
        await Notification.create({
            user_id: userId,
            type: 'WON_AUCTION',
            title: 'Giao dịch thành công',
            message: `Bạn đã xác nhận nhận hàng thành công. Cảm ơn bạn đã sử dụng dịch vụ.`,
            related_id: auction._id
        });

        res.json({ success: true, message: 'Receipt confirmed and funds released' });

    } catch (error) {
        console.error('Confirmation error:', error);
        res.status(500).json({ error: 'Internal server error', details: error.message });
    }
});

module.exports = router;
