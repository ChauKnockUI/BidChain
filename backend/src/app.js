const express = require("express");
const http = require("http");
const cors = require("cors");
const mongoose = require("mongoose");
require("dotenv").config();

const authRoutes = require("./routes/auth");
const auctionRoutes = require("./routes/auction");
const userRoutes = require("./routes/user");
const paymentRoutes = require("./routes/payment");
const adminRoutes = require("./routes/admin/adminUser");
const Auction = require("./models/Auction");
const Bid = require("./models/Bid");
const categoryRoutes = require('./routes/categoryRoutes');
const locationRoutes = require('./routes/location');
const Notification = require("./models/Notification");
const { weiToVnd, formatVnd } = require("./utils/conversion");
const adminAuctionRouter = require('./routes/admin/adminAuction');
const adminDashboardRouter = require('./routes/admin/adminDashboard');
const confirmRoutes = require("./routes/confirm");

const app = express();
app.use(cors());
app.use(express.json());

app.use("/api/category", categoryRoutes);
app.use("/api/auth", authRoutes);
app.use("/api/auction", auctionRoutes);
app.use("/api/user", userRoutes);
app.use("/api/users", userRoutes); // Alias for plural usage
app.use("/api/payment", paymentRoutes);
app.use("/api/location", locationRoutes);

app.use("/api/confirm", confirmRoutes);
app.use("/api/admin", adminRoutes);

app.use('/api/admin/auctions', adminAuctionRouter);
app.use('/api/admin/dashboard', adminDashboardRouter);

const uploadRouter = require("./routes/upload");
const { AUCTION_STATUS } = require("./config/constants");
app.use("/api/upload", uploadRouter);
const server = http.createServer(app);
const io = require("socket.io")(server, {
  cors: { origin: "*" },
});

// Make io available to routes
app.set('io', io);

// Make io globally available for cron jobs
global.io = io;

// Import and start settlement cron
const { runSettlementCron } = require('./cron/settlement');
setInterval(runSettlementCron, 20000); // Run every minute
console.log('Settlement cron job started (runs every 60s)');

// Import and start integrity cron (auto-restore tampered bids)
const { startIntegrityCron } = require('./cron/integrity');
startIntegrityCron();


// socket
io.on("connection", (socket) => {
  console.log("New client:", socket.id);

  socket.on("join_room", (auctionId) => {
    const roomName = `auction_room_${auctionId}`;
    socket.join(roomName);
    console.log(`Client ${socket.id} joined room ${roomName}`);
  });

  socket.on("disconnect", () => {
    console.log("Client disconnected:", socket.id);
  });
});
console.log("Starting auction management system...");

// Socket.IO event handlers for real-time bidding
io.on("connection", (socket) => {
  console.log("New client:", socket.id);

  socket.on("join_auction", (auctionId) => {
    const roomName = `auction_${auctionId}`;
    socket.join(roomName);
    console.log(`Client ${socket.id} joined auction room ${roomName}`);
  });

  socket.on("join_user_room", (userId) => {
    const roomName = `user_${userId}`;
    socket.join(roomName);
    console.log(`Client ${socket.id} joined user room ${roomName}`);
  });

  socket.on("leave_auction", (auctionId) => {
    const roomName = `auction_${auctionId}`;
    socket.leave(roomName);
    console.log(`Client ${socket.id} left auction room ${roomName}`);
  });

  socket.on("disconnect", () => {
    console.log("Client disconnected:", socket.id);
  });
});

// Cron job to manage auction lifecycle
const manageAuctions = async () => {
  try {
    const now = new Date();

    // 1. Activate approved auctions when start time arrives
    const auctionsToActivate = await Auction.find({
      status: AUCTION_STATUS.APPROVED,
      start_time: { $lte: now },
      end_time: { $gt: now }
    }).populate('seller_id');

    for (const auction of auctionsToActivate) {
      await Auction.findByIdAndUpdate(auction._id, {
        status: AUCTION_STATUS.ACTIVE
      });

      console.log(`Auction ${auction._id} activated: ${auction.title}`);

      // Notify seller that auction is now active
      const Notification = require('./models/Notification');
      await Notification.create({
        user_id: auction.seller_id._id,
        type: 'AUCTION_STARTED',
        title: 'Phiên đấu giá đã bắt đầu',
        message: `Phiên đấu giá "${auction.title}" đã bắt đầu và đang nhận bids.`,
        related_id: auction._id
      });

      // Broadcast to all users
      if (global.io) {
        global.io.emit('auction_started', {
          auction_id: auction._id,
          title: auction.title,
          start_price_vnd: require('./utils/conversion').weiToVnd(auction.start_price.toString()),
          end_time: auction.end_time
        });
      }
    }

    /* 
    // 2. Settle expired auctions -> MOVED TO src/cron/settlement.js to avoid conflicts
    const expiredAuctions = await Auction.find({
      status: AUCTION_STATUS.ACTIVE,
      end_time: { $lt: now }
    }).populate('seller_id', 'wallet_address').populate('highest_bidder_id', 'wallet_address');

    for (const auction of expiredAuctions) {
      // Update auction status
      await Auction.findByIdAndUpdate(auction._id, { status: 'ENDED' });

      // Update winning bid status if any
      if (auction.highest_bidder_id) {
        await Bid.updateMany(
          { auction_id: auction._id, status: 'WINNING' },
          { status: 'WINNING' }
        );
      }

      // Notify winner
      if (auction.highest_bidder_id) {
        const notification = new Notification({
          user_id: auction.highest_bidder_id,
          type: 'WON_AUCTION',
          title: 'Chúc mừng! Bạn đã thắng đấu giá',
          message: `Bạn đã thắng phiên đấu giá với giá ${formatVnd(weiToVnd(auction.current_price.toString()))}`,
          related_id: auction._id
        });
        await notification.save();

        io.to(`user_${auction.highest_bidder_id}`).emit('auction_won', {
          auction_id: auction._id,
          title: auction.title,
          final_price_vnd: weiToVnd(auction.current_price.toString()),
          formatted_final_price: formatVnd(weiToVnd(auction.current_price.toString()))
        });
      }

      // Broadcast auction end to room
      io.to(`auction_${auction._id}`).emit('auction_ended', {
        auction_id: auction._id,
        winner_id: auction.highest_bidder_id,
        final_price_wei: auction.current_price.toString(),
        final_price_vnd: weiToVnd(auction.current_price.toString()),
        formatted_final_price: formatVnd(weiToVnd(auction.current_price.toString()))
      });

      console.log(`Auction ${auction._id} settled. Winner: ${auction.highest_bidder_id || 'None'}`);
    }
    */
  } catch (error) {
    console.error('Error managing auctions:', error);
  }
};

// Run auction management every minute
setInterval(manageAuctions, 60000);
const PORT = process.env.PORT || 3000;

mongoose
  .connect(process.env.MONGO_URI)
  .then(() => {
    server.listen(PORT, () => {
      console.log("Backend running at http://localhost:" + PORT);
    });
  })
  .catch((err) => console.log("Mongo error:", err));
