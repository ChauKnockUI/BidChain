const express = require("express");
const http = require("http");
const cors = require("cors");
const mongoose = require("mongoose");
require("dotenv").config();

const authRoutes = require("./routes/auth");
const auctionRoutes = require("./routes/auction");
const userRoutes = require("./routes/user");
const { ethers } = require("ethers");
const { contract } = require("./blockchain/contract");
const OffchainAuction = require("./models/OffchainAuction");

const app = express();
app.use(cors());
app.use(express.json());

app.use("/api/auth", authRoutes);
app.use("/api/auction", auctionRoutes);
app.use("/api/user", userRoutes);
const uploadRouter = require("./routes/upload");
app.use("/api/upload", uploadRouter);
const server = http.createServer(app);
const io = require("socket.io")(server, {
  cors: { origin: "*" },
});

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
console.log("Starting blockchain event listeners...");

// blockchain events
contract.on("AuctionCreated", async (auctionId, seller, startingPrice, endTime, metadataUrl) => {
  console.log(`[Event] AuctionCreated: ID ${auctionId}`);
  try {
    // MỚI: Đồng bộ vào DB
    const newAuction = new OffchainAuction({
      auctionId: Number(auctionId), // Ethers v5 trả về BigNumber, cần chuyển đổi
      seller: seller,
      startingPrice: startingPrice.toString(),
      highestBid: startingPrice.toString(), // Ban đầu, giá cao nhất = giá khởi điểm
      highestBidder: ethers.constants.AddressZero, // Địa chỉ 0x0
      endTime: new Date(Number(endTime) * 1000), // Chuyển timestamp (s) sang Date (ms)
      metadataUrl: metadataUrl, // (Lưu ý: Smart Contract của bạn cần emit cả metadataUrl)
      ended: false,
    });
    await newAuction.save();

    // HOÀN THIỆN: Chỉ phát sóng cho mọi người (không cần vào phòng)
    io.emit("AuctionCreated", {
      auctionId: auctionId.toString(),
      seller,
      startingPrice: ethers.utils.formatEther(startingPrice), // Dùng Ether
      endTime: Number(endTime),
      metadataUrl: metadataUrl
    });
  } catch (err) {
    console.error("Error syncing AuctionCreated:", err);
  }
});

contract.on("NewBid", async (auctionId, bidder, amount) => {
  console.log(`[Event] NewBid on ${auctionId} by ${bidder}`);
  try {
    // MỚI: Cập nhật DB
    const updatedAuction = await OffchainAuction.findOneAndUpdate(
      { auctionId: Number(auctionId) },
      {
        highestBidder: bidder,
        highestBid: amount.toString(),
      },
      { new: true } // Trả về document đã cập nhật
    );

    if (updatedAuction) {
      const data = {
        auctionId: auctionId.toString(),
        bidder,
        amount: ethers.utils.formatEther(amount), // Dùng Ether
      };
      // HOÀN THIỆN: Chỉ phát sóng cho những người trong phòng
      const roomName = `auction_room_${auctionId}`;
      io.to(roomName).emit("NewBid", data);
    }
  } catch (err) {
    console.error("Error syncing NewBid:", err);
  }
});

contract.on("AuctionEnded", async (auctionId, winner, finalAmount) => {
  console.log(`[Event] AuctionEnded: ID ${auctionId}`);
  try {
    // MỚI: Cập nhật DB
    const updatedAuction = await OffchainAuction.findOneAndUpdate(
      { auctionId: Number(auctionId) },
      {
        ended: true,
        winner: winner,
      },
      { new: true }
    );

    if (updatedAuction) {
      const data = {
        auctionId: auctionId.toString(),
        winner,
        finalAmount: ethers.utils.formatEther(finalAmount), // Dùng Ether
      };
      // HOÀN THIỆN: Chỉ phát sóng cho những người trong phòng
      const roomName = `auction_room_${auctionId}`;
      io.to(roomName).emit("AuctionEnded", data);
    }
  } catch (err) {
    console.error("Error syncing AuctionEnded:", err);
  }
});
const PORT = process.env.PORT || 3000;

mongoose
  .connect(process.env.MONGO_URI)
  .then(() => {
    server.listen(PORT, () => {
      console.log("Backend running at http://localhost:" + PORT);
    });
  })
  .catch((err) => console.log("Mongo error:", err));
