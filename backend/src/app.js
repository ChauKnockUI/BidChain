const express = require("express");
const http = require("http");
const cors = require("cors");
const mongoose = require("mongoose");
require("dotenv").config();

const authRoutes = require("./routes/auth");
const auctionRoutes = require("./routes/auction");
const { contract } = require("./blockchain/contract");
const OffchainAuction = require("./models/OffchainAuction");

const app = express();
app.use(cors());
app.use(express.json());

app.use("/api/auth", authRoutes);
app.use("/api/auction", auctionRoutes);

const server = http.createServer(app);
const io = require("socket.io")(server, {
  cors: { origin: "*" },
});

// socket
io.on("connection", (socket) => {
  console.log("New client:", socket.id);
});

// blockchain events
contract.on("AuctionCreated", (auctionId, seller, startingPrice, endTime) => {
  io.emit("AuctionCreated", {
    auctionId: auctionId.toString(),
    seller,
    startingPrice: startingPrice.toString(),
    endTime: Number(endTime),
  });
});

contract.on("NewBid", (auctionId, bidder, amount) => {
  io.emit("NewBid", {
    auctionId: auctionId.toString(),
    bidder,
    amount: amount.toString(),
  });
});

contract.on("AuctionEnded", (auctionId, winner, finalAmount) => {
  io.emit("AuctionEnded", {
    auctionId: auctionId.toString(),
    winner,
    finalAmount: finalAmount.toString(),
  });
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
