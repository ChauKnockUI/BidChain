const User = require('../models/User');
const Auction = require('../models/Auction');
const Notification = require('../models/Notification');
const { weiToEth, formatVnd } = require('../utils/conversion');

/**
 * Middleware to emit socket events after successful bid
 * Must be placed AFTER handleBidLocking middleware
 */
const emitBidEvents = async (req, res, next) => {
    try {
        const { bid, previousBidder } = req.bidResult;
        const auctionId = req.body.auction_id;
        const userId = req.user.id;
        const io = req.app.get('io');

        if (!io) {
            console.warn('Socket.IO not available, skipping realtime events');
            return next();
        }

        // Fetch auction and user details for socket events
        const [auction, currentUser] = await Promise.all([
            Auction.findById(auctionId).populate('seller_id', 'full_name'),
            User.findById(userId)
        ]);

        if (!auction) {
            console.error('Auction not found for socket emission');
            return next();
        }

        // 1. Emit new_bid to auction room (for real-time price update on auction detail page)
        io.to(`auction_${auctionId}`).emit('new_bid', {
            auction_id: auctionId,
            bid_id: bid._id.toString(),
            amount_vnd: bid.amount_vnd,
            amount_wei: bid.amount_wei,
            formatted_amount: formatVnd(bid.amount_vnd),
            bidder_id: userId,
            created_at: bid.created_at
        });
        console.log(`✅ Emitted new_bid to auction_${auctionId}`);

        // 2. Emit balance_updated to current bidder
        const balanceWei = BigInt(currentUser.balance_eth || "0");
        const lockedWei = BigInt(currentUser.locked_eth || "0");
        const availableWei = balanceWei - lockedWei;

        io.to(`user_${userId}`).emit('balance_updated', {
            balance_eth: weiToEth(balanceWei.toString()),
            locked_eth: weiToEth(lockedWei.toString()),
            available_eth: weiToEth(availableWei.toString())
        });
        console.log(`✅ Emitted balance_updated to user_${userId}`);

        // 3. Handle previous bidder (if different user)
        if (previousBidder && previousBidder.toString() !== userId) {
            const prevUser = await User.findById(previousBidder);

            if (prevUser) {
                // Emit balance_updated to previous bidder (funds unlocked)
                const prevBalanceWei = BigInt(prevUser.balance_eth || "0");
                const prevLockedWei = BigInt(prevUser.locked_eth || "0");
                const prevAvailableWei = prevBalanceWei - prevLockedWei;

                io.to(`user_${previousBidder}`).emit('balance_updated', {
                    balance_eth: weiToEth(prevBalanceWei.toString()),
                    locked_eth: weiToEth(prevLockedWei.toString()),
                    available_eth: weiToEth(prevAvailableWei.toString())
                });
                console.log(`✅ Emitted balance_updated to previous bidder user_${previousBidder}`);

                // Create and emit OUTBID notification
                const outbidNotif = await Notification.create({
                    user_id: previousBidder,
                    type: 'OUTBID',
                    title: 'Bạn đã bị vượt giá',
                    message: `Có người vừa đặt giá ${formatVnd(bid.amount_vnd)} cao hơn bạn trong phiên đấu giá "${auction.title}".`,
                    related_id: auctionId
                });

                io.to(`user_${previousBidder}`).emit('notification', {
                    ...outbidNotif.toObject(),
                    _id: outbidNotif._id.toString()
                });
                console.log(`✅ Emitted OUTBID notification to user_${previousBidder}`);
            }
        }

        // 4. Notify Seller about new bid
        if (auction.seller_id && auction.seller_id._id.toString() !== userId) {
            const sellerNotif = await Notification.create({
                user_id: auction.seller_id._id,
                type: 'NEW_BID',
                title: 'Có lượt đặt giá mới',
                message: `Đã có người đặt giá ${formatVnd(bid.amount_vnd)} cho phiên đấu giá "${auction.title}"`,
                related_id: auctionId
            });

            io.to(`user_${auction.seller_id._id}`).emit('notification', {
                ...sellerNotif.toObject(),
                _id: sellerNotif._id.toString()
            });
            console.log(`✅ Emitted NEW_BID notification to seller user_${auction.seller_id._id}`);
        }

        next();
    } catch (error) {
        console.error('Error in emitBidEvents middleware:', error);
        // Don't block the response, just log the error
        next();
    }
};

/**
 * Emit balance update and notification for deposit success
 */
const emitDepositSuccess = async (userId, amountVnd, io) => {
    try {
        if (!io) return;

        const user = await User.findById(userId);
        if (!user) return;

        // Emit balance update
        const balanceWei = BigInt(user.balance_eth || "0");
        const lockedWei = BigInt(user.locked_eth || "0");
        const availableWei = balanceWei - lockedWei;

        io.to(`user_${userId}`).emit('balance_updated', {
            balance_eth: weiToEth(balanceWei.toString()),
            locked_eth: weiToEth(lockedWei.toString()),
            available_eth: weiToEth(availableWei.toString())
        });

        // Create and emit notification
        const notif = await Notification.create({
            user_id: userId,
            type: 'DEPOSIT_SUCCESS',
            title: 'Nạp tiền thành công',
            message: `Giao dịch nạp ${formatVnd(amountVnd)} đã hoàn tất.`
        });

        io.to(`user_${userId}`).emit('notification', {
            ...notif.toObject(),
            _id: notif._id.toString()
        });

        console.log(`✅ Emitted deposit success events to user_${userId}`);
    } catch (error) {
        console.error('Error in emitDepositSuccess:', error);
    }
};

/**
 * Emit balance update and notification for withdrawal success
 */
const emitWithdrawSuccess = async (userId, amountVnd, io) => {
    try {
        if (!io) return;

        const user = await User.findById(userId);
        if (!user) return;

        // Emit balance update
        const balanceWei = BigInt(user.balance_eth || "0");
        const lockedWei = BigInt(user.locked_eth || "0");
        const availableWei = balanceWei - lockedWei;

        io.to(`user_${userId}`).emit('balance_updated', {
            balance_eth: weiToEth(balanceWei.toString()),
            locked_eth: weiToEth(lockedWei.toString()),
            available_eth: weiToEth(availableWei.toString())
        });

        // Create and emit notification
        const notif = await Notification.create({
            user_id: userId,
            type: 'WITHDRAW_SUCCESS',
            title: 'Rút tiền thành công',
            message: `Bạn đã rút thành công ${formatVnd(amountVnd)} từ tài khoản.`
        });

        io.to(`user_${userId}`).emit('notification', {
            ...notif.toObject(),
            _id: notif._id.toString()
        });

        console.log(`✅ Emitted withdraw success events to user_${userId}`);
    } catch (error) {
        console.error('Error in emitWithdrawSuccess:', error);
    }
};

module.exports = {
    emitBidEvents,
    emitDepositSuccess,
    emitWithdrawSuccess
};
