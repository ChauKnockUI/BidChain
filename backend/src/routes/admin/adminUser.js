const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const { body, param, query, validationResult } = require('express-validator');
const User = require('../../models/User');
const Transaction = require('../../models/Transaction');
const DepositRequest = require('../../models/DepositRequest');
const Bid = require('../../models/Bid');
const Auction = require('../../models/Auction');
const { authMiddleware } = require('../../middleware/auth');
const { weiToVnd, weiToEth, formatVnd } = require('../../utils/conversion');
const { TRANSACTION_TYPES } = require('../../config/constants');
const jwt = require('jsonwebtoken');
require('dotenv').config();



// GET /api/admin/logs/events - realtime events (NewBid, AuctionEnded, Deposit, Withdraw)
// router.get('/logs/events', authMiddleware, requireAdmin, [query('type').optional().isIn(['new_bid','auction_ended','deposit','withdraw','all']), query('page').optional().toInt(), query('limit').optional().toInt(), query('q').optional().isString(), query('since').optional().isISO8601()], async (req, res) => {
// 	const errors = validationResult(req);
// 	if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

// 	try {
// 		const type = req.query.type || 'all';
// 		const page = req.query.page && req.query.page > 0 ? req.query.page : 1;
// 		const limit = req.query.limit && req.query.limit > 0 ? req.query.limit : 20;
// 		const q = req.query.q;
// 		const since = req.query.since ? new Date(req.query.since) : null;
// 		const fetchCount = page * limit; // fetch enough per-type for sorting

// 		// helper: find matching user ids and auction ids if q provided
// 		let userIds = null;
// 		let auctionIds = null;
// 		if (q) {
// 			const users = await User.find({ $or: [{ username: new RegExp(q, 'i') }, { email: new RegExp(q, 'i') }, { full_name: new RegExp(q, 'i') }] }).select('_id');
// 			userIds = users.map(u => u._id);
// 			const auctions = await Auction.find({ title: new RegExp(q, 'i') }).select('_id');
// 			auctionIds = auctions.map(a => a._id);
// 		}

// 		const events = [];

// 		// Collect bids as NEW_BID events
// 		if (type === 'new_bid' || type === 'all') {
// 			const bidFilter = {};
// 			if (since) bidFilter.createdAt = { $gte: since };
// 			if (userIds && userIds.length) bidFilter.user_id = { $in: userIds };
// 			if (auctionIds && auctionIds.length) bidFilter.auction_id = { $in: auctionIds };
// 			const bids = await Bid.find(bidFilter).populate('user_id', 'username email').populate('auction_id', 'title').sort({ createdAt: -1 }).limit(fetchCount);
// 			for (const b of bids) {
// 				events.push({
// 					event_type: 'NEW_BID',
// 					created_at: b.createdAt || b.created_at || new Date(),
// 					user: { id: b.user_id?._id, username: b.user_id?.username, email: b.user_id?.email },
// 					details: {
// 						bid_id: b._id,
// 						auction_id: b.auction_id?._id,
// 						auction_title: b.auction_id?.title,
// 						amount_wei: b.amount_wei,
// 						amount_vnd: weiToVnd(b.amount_wei ? b.amount_wei.toString() : '0'),
// 						status: b.status
// 					}
// 				});
// 			}
// 		}

// 		// Collect auctions ended as AUCTION_ENDED events
// 		if (type === 'auction_ended' || type === 'all') {
// 			const auctionFilter = { status: { $in: ['ENDED', 'SETTLED'] } };
// 			if (since) auctionFilter.updatedAt = { $gte: since };
// 			if (auctionIds && auctionIds.length) auctionFilter._id = { $in: auctionIds };
// 			const auctions = await Auction.find(auctionFilter).populate('highest_bidder_id', 'username email').populate('seller_id', 'username email').sort({ updatedAt: -1 }).limit(fetchCount);
// 			for (const a of auctions) {
// 				events.push({
// 					event_type: 'AUCTION_ENDED',
// 					created_at: a.updatedAt || a.approved_at || a.end_time || a.createdAt || a.created_at,
// 					user: { id: a.highest_bidder_id?._id || a.seller_id?._id, username: a.highest_bidder_id?.username || a.seller_id?.username, email: a.highest_bidder_id?.email || a.seller_id?.email },
// 					details: {
// 						auction_id: a._id,
// 						auction_title: a.title,
// 						final_price_wei: a.current_price,
// 						final_price_vnd: weiToVnd(a.current_price ? a.current_price.toString() : '0'),
// 						winner_id: a.highest_bidder_id?._id
// 					}
// 				});
// 			}
// 		}

// 		// Collect transactions (DEPOSIT / WITHDRAW)
// 		if (type === 'deposit' || type === 'all' || type === 'withdraw') {
// 			const txFilter = {};
// 			if (since) txFilter.created_at = { $gte: since };
// 			if (userIds && userIds.length) txFilter.user_id = { $in: userIds };
// 			if (type === 'deposit') txFilter.type = 'DEPOSIT';
// 			if (type === 'withdraw') txFilter.type = 'WITHDRAW';
// 			// if type === 'all', include both - leave txFilter.type unset
// 			const txs = await Transaction.find(txFilter).populate('user_id', 'username email').sort({ created_at: -1 }).limit(fetchCount);
// 			for (const t of txs) {
// 				events.push({
// 					event_type: t.type === 'DEPOSIT' ? 'DEPOSIT' : t.type === 'WITHDRAW' ? 'WITHDRAW' : 'TRANSACTION',
// 					created_at: t.created_at,
// 					user: { id: t.user_id?._id, username: t.user_id?.username, email: t.user_id?.email },
// 					details: {
// 						tx_id: t._id,
// 						amount_eth: t.amount_eth ? parseFloat(t.amount_eth.toString()) : 0,
// 						amount_vnd: t.amount_vnd ? parseFloat(t.amount_vnd.toString()) : 0,
// 						status: t.status,
// 						tx_hash: t.tx_hash
// 					}
// 				});
// 			}
// 		}

// 		// Sort events by created_at desc and then paginate
// 		events.sort((a,b) => new Date(b.created_at) - new Date(a.created_at));
// 		const start = (page - 1) * limit;
// 		const end = start + limit;
// 		const paged = events.slice(start, end);

// 		return res.json({ total: events.length, page, limit, events: paged });
// 	} catch (err) {
// 		console.error('Admin logs events error', err);
// 		return res.status(500).json({ error: 'Failed to fetch events' });
// 	}
// });

// Helper: require admin role
async function requireAdmin(req, res, next) {
	try {
		const requester = await User.findById(req.user.id);
		if (!requester) return res.status(404).json({ error: 'Requesting user not found' });
		if (requester.role !== 'ADMIN') return res.status(403).json({ error: 'Admin access required' });
		req.requester = requester;
		return next();
	} catch (err) {
		console.error('Admin check error', err);
		return res.status(500).json({ error: 'Internal server error' });
	}
}


router.post(
  '/login_admin',
  [
    body('username').notEmpty().withMessage('Username required'),
    body('password').notEmpty().withMessage('Password required')
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { username, password } = req.body;

    try {
      // Tìm user theo username và role = ADMIN
      const adminUser = await User.findOne({ username, role: 'ADMIN' });
      if (!adminUser) {
        return res.status(401).json({ error: 'Invalid username or password' });
      }

      // Kiểm tra mật khẩu
      const isMatch = await bcrypt.compare(password, adminUser.password_hash);
      if (!isMatch) {
        return res.status(401).json({ error: 'Invalid username or password' });
      }

      // Tạo JWT
      const token = jwt.sign(
        { id: adminUser._id, role: adminUser.role },
        process.env.JWT_SECRET,
        { expiresIn: '12h' }
      );

      return res.json({ token, role: adminUser.role });
    } catch (err) {
      console.error('Admin login error', err);
      return res.status(500).json({ error: 'Server error' });
    }
  }
);


// GET /api/admin/users - list users (with pagination & filters)
router.get(
	'/users',
	authMiddleware,
	requireAdmin,
	[query('page').optional().toInt(), query('limit').optional().toInt(), query('q').optional().isString()],
	async (req, res) => {
		try {
			const page = req.query.page && req.query.page > 0 ? req.query.page : 1;
			const limit = req.query.limit && req.query.limit > 0 ? req.query.limit : 20;
			const q = req.query.q;
			const status = req.query.status; // ACTIVE | BANNED
			const role = req.query.role; // ADMIN | MANAGER | USER

			const filter = {};
			if (q) {
				filter.$or = [{ username: new RegExp(q, 'i') }, { email: new RegExp(q, 'i') }, { full_name: new RegExp(q, 'i') }];
			}
			if (status) filter.status = status;
			if (role) filter.role = role;

			const total = await User.countDocuments(filter);
			const users = await User.find(filter)
				.select('-password_hash -encrypted_private_key')
				.skip((page - 1) * limit)
				.limit(limit)
				.sort({ created_at: -1 });

			const data = users.map(u => ({
				id: u._id,
				username: u.username,
				email: u.email,
				full_name: u.full_name,
				wallet_address: u.wallet_address,
				role: u.role,
				status: u.status,
				balance_eth: weiToEth(u.balance_eth),
				balance_vnd: weiToVnd(u.balance_eth),
				formatted_balance: formatVnd(weiToVnd(u.balance_eth)),
				locked_eth: weiToEth(u.locked_eth),
				locked_vnd: weiToVnd(u.locked_eth),
				created_at: u.created_at
			}));

			return res.json({ total, page, limit, users: data });
		} catch (err) {
			console.error('Admin list users error', err);
			return res.status(500).json({ error: 'Failed to fetch users' });
		}
	}
);


// GET /api/admin/users/:id - get one user details
router.get('/users/:id', authMiddleware, requireAdmin, [param('id').isMongoId()], async (req, res) => {
	const errors = validationResult(req);
	if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });
	try {
		const user = await User.findById(req.params.id).select('-password_hash -encrypted_private_key');
		if (!user) return res.status(404).json({ error: 'User not found' });

		return res.json({
			id: user._id,
			username: user.username,
			email: user.email,
			full_name: user.full_name,
			avatar: user.avatar,
			momo_phone: user.momo_phone,
			wallet_address: user.wallet_address,
			role: user.role,
			status: user.status,
			balance_eth: weiToEth(user.balance_eth),
			locked_eth: weiToEth(user.locked_eth),
			balance_vnd: weiToVnd(user.balance_eth),
			locked_vnd: weiToVnd(user.locked_eth),
			formatted_balance: formatVnd(weiToVnd(user.balance_eth)),
			created_at: user.created_at
		});
	} catch (err) {
		console.error('Admin get user error', err);
		return res.status(500).json({ error: 'Server error' });
	}
});

// PUT /api/admin/users/:id - edit user info
router.put('/users/:id', authMiddleware, requireAdmin, [param('id').isMongoId(), body('full_name').optional().trim(), body('avatar').optional().isString(), body('momo_phone').optional().isString(), body('email').optional().isEmail()], async (req, res) => {
	const errors = validationResult(req);
	if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });
	try {
		const updates = {};
		const { full_name, avatar, momo_phone, email } = req.body;
		if (full_name) updates.full_name = full_name;
		if (avatar) updates.avatar = avatar;
		if (momo_phone !== undefined) updates.momo_phone = momo_phone;
		if (email) updates.email = email.toLowerCase().trim();

		const user = await User.findByIdAndUpdate(req.params.id, { $set: updates }, { new: true, runValidators: true }).select('-password_hash -encrypted_private_key');
		if (!user) return res.status(404).json({ error: 'User not found' });
		return res.json({ success: true, message: 'User updated', user });
	} catch (err) {
		console.error('Admin update user error', err);
		return res.status(500).json({ error: 'Failed to update user' });
	}
});

// POST /api/admin/users/:id/reset-password - reset password
router.post('/users/:id/reset-password', authMiddleware, requireAdmin, [param('id').isMongoId(), body('new_password').optional().isLength({ min: 8 })], async (req, res) => {
	const errors = validationResult(req);
	if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });
	try {
		const { new_password } = req.body;
		if (!new_password) return res.status(400).json({ error: 'new_password required' });
		const salt = await bcrypt.genSalt(10);
		const password_hash = await bcrypt.hash(new_password, salt);
		const user = await User.findByIdAndUpdate(req.params.id, { $set: { password_hash } });
		if (!user) return res.status(404).json({ error: 'User not found' });
		return res.json({ success: true, message: 'Password reset' });
	} catch (err) {
		console.error('Admin reset password error', err);
		return res.status(500).json({ error: 'Failed to reset password' });
	}
});

// PATCH /api/admin/users/:id/status - lock/unlock user
router.patch('/users/:id/status', authMiddleware, requireAdmin, [param('id').isMongoId(), body('status').isIn(['ACTIVE', 'BANNED'])], async (req, res) => {
	const errors = validationResult(req);
	if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });
	try {
		const { status } = req.body;
		const user = await User.findByIdAndUpdate(req.params.id, { $set: { status } }, { new: true });
		if (!user) return res.status(404).json({ error: 'User not found' });
		return res.json({ success: true, message: `User status set to ${status}`, user: { id: user._id, username: user.username, status: user.status } });
	} catch (err) {
		console.error('Admin update user status error', err);
		return res.status(500).json({ error: 'Failed to update status' });
	}
});

// PATCH /api/admin/users/:id/role - change role (USER or MANAGER)
router.patch('/users/:id/role', authMiddleware, requireAdmin, [param('id').isMongoId(), body('role').isIn(['USER', 'MANAGER'])], async (req, res) => {
	const errors = validationResult(req);
	if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });
	try {
		const { role } = req.body;
		// Prevent demoting yourself accidentally
		if (req.params.id.toString() === req.user.id.toString() && role !== 'ADMIN') {
			// If the requester is changing their own role, prevent setting to non-admin
			return res.status(400).json({ error: 'Cannot change your own admin role via this endpoint' });
		}

		const user = await User.findByIdAndUpdate(req.params.id, { $set: { role } }, { new: true });
		if (!user) return res.status(404).json({ error: 'User not found' });
		return res.json({ success: true, message: `Role set to ${role}`, user: { id: user._id, username: user.username, role: user.role } });
	} catch (err) {
		console.error('Admin change role error', err);
		return res.status(500).json({ error: 'Failed to change role' });
	}
});

// GET /api/admin/users/:id/history - get user activity history type=deposit|withdraw|bid|all
router.get('/users/:id/history', authMiddleware, requireAdmin, [param('id').isMongoId(), query('type').optional().isIn(['deposit','withdraw','bid','all']), query('page').optional().toInt(), query('limit').optional().toInt()], async (req, res) => {
	const errors = validationResult(req);
	if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });
	try {
		const page = req.query.page && req.query.page > 0 ? req.query.page : 1;
		const limit = req.query.limit && req.query.limit > 0 ? req.query.limit : 20;
		const type = req.query.type || 'all';
		const userId = req.params.id;
		const result = {};

		if (type === 'deposit' || type === 'all') {
			const [transactions, count] = await Promise.all([
				Transaction.find({ user_id: userId, type: 'DEPOSIT' }).sort({ created_at: -1 }).skip((page - 1) * limit).limit(limit),
				Transaction.countDocuments({ user_id: userId, type: 'DEPOSIT' })
			]);
			result.deposits = transactions.map(t => ({ id: t._id, amount_eth: parseFloat(t.amount_eth || 0), amount_vnd: parseFloat(t.amount_vnd || 0), status: t.status, tx_hash: t.tx_hash, created_at: t.created_at }));
			result.deposit_count = count;
		}

		if (type === 'withdraw' || type === 'all') {
			const [txs, count] = await Promise.all([
				Transaction.find({ user_id: userId, type: 'WITHDRAW' }).sort({ created_at: -1 }).skip((page - 1) * limit).limit(limit),
				Transaction.countDocuments({ user_id: userId, type: 'WITHDRAW' })
			]);
			result.withdraws = txs.map(t => ({ id: t._id, amount_eth: parseFloat(t.amount_eth || 0), amount_vnd: parseFloat(t.amount_vnd || 0), status: t.status, tx_hash: t.tx_hash, created_at: t.created_at }));
			result.withdraw_count = count;
		}

		if (type === 'bid' || type === 'all') {
			const [bids, count] = await Promise.all([
				Bid.find({ user_id: userId }).populate('auction_id','title').sort({ created_at: -1 }).skip((page - 1) * limit).limit(limit),
				Bid.countDocuments({ user_id: userId })
			]);
			result.bids = bids.map(b => ({ id: b._id, auction_id: b.auction_id?._id, auction_title: b.auction_id?.title, amount_wei: b.amount_wei, amount_vnd: weiToVnd(b.amount_wei ? b.amount_wei.toString() : '0'), status: b.status, created_at: b.created_at }));
			result.bid_count = count;
		}

		return res.json({ page, limit, ...result });
	} catch (err) {
		console.error('Admin user history error', err);
		return res.status(500).json({ error: 'Failed to fetch history' });
	}
});

module.exports = router;


