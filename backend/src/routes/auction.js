const express = require("express");
const router = express.Router();
const jwt = require("jsonwebtoken");
const User = require("../models/User");
const OffchainAuction = require("../models/OffchainAuction");
const BidHistory = require("../models/BidHistory");
const { ethers } = require("ethers");
const { decrypt } = require("../utils/crypto");
require("dotenv").config();

// Provider (Ethers v5)
const provider = new ethers.providers.JsonRpcProvider(process.env.GANACHE_RPC);

// Load ABI + Contract
const contractJson = require("../../abi/Auction.json");
const contract = new ethers.Contract(
    process.env.CONTRACT_ADDRESS,
    contractJson.abi,
    provider
);

// Middleware xác thực token
function auth(req, res, next) {
    const header = req.headers.authorization;
    if (!header) return res.status(401).json({ error: "Missing token" });

    try {
        const token = header.split(" ")[1];
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.userId = decoded.id;
        next();
    } catch (e) {
        return res.status(401).json({ error: "Invalid token" });
    }
}

// ========== API LẤY SỐ DƯ ==========  
router.get("/wallet/balance", auth, async (req, res) => {
    const user = await User.findById(req.userId);
    if (!user) return res.status(404).json({ error: "User not found" });

    const balance = await provider.getBalance(user.ethAddress);

    return res.json({
        address: user.ethAddress,
        balance: balance.toString()
    });
});

// ========== API TẠO AUCTION ==========  
router.post("/create", auth, async (req, res) => {
    try {
        const { startingPriceWei, durationSeconds, metadataUrl } = req.body;

        const user = await User.findById(req.userId);
        if (!user) return res.status(404).json({ error: "User not found" });

        const privateKey = decrypt(user.encryptedPrivateKey, process.env.MASTER_KEY);
        const wallet = new ethers.Wallet(privateKey, provider);

        const tx = await contract.connect(wallet).createAuction(
            startingPriceWei,
            durationSeconds,
            metadataUrl
        );

        const receipt = await tx.wait();
        const iface = contract.interface;
        const topic = iface.getEventTopic("AuctionCreated");

        let auctionId = null;

        for (const log of receipt.logs) {
            if (log.topics[0] === topic) {
                const decoded = iface.decodeEventLog(
                    "AuctionCreated",
                    log.data,
                    log.topics
                );
                auctionId = decoded.auctionId.toString();
                break;
            }
        }

        if (!auctionId) {
            return res.status(500).json({ error: "Event AuctionCreated not found" });
        }

        //  Lưu auction vào MongoDB
        await OffchainAuction.create({
            auctionId: auctionId,
            seller: user.ethAddress,
            metadataUrl,
            startingPrice: startingPriceWei,
            highestBid: "0",
            highestBidder: null,
            endTime: Date.now() + durationSeconds * 1000,
            ended: false
        });

        return res.json({
            txHash: receipt.transactionHash,
            auctionId
        });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: err.message });
    }
});

// ========== API ĐẶT GIÁ ==========  
router.post("/bid", auth, async (req, res) => {
    try {
        const { auctionId, amountWei } = req.body;

        const user = await User.findById(req.userId);
        if (!user) return res.status(404).json({ error: "User not found" });

        const privateKey = decrypt(user.encryptedPrivateKey, process.env.MASTER_KEY);
        const wallet = new ethers.Wallet(privateKey, provider);

        const tx = await contract.connect(wallet).bid(auctionId, {
            value: amountWei
        });

        const receipt = await tx.wait();

        // Lưu lịch sử bid
        await BidHistory.create({
            auctionId,
            bidder: user.ethAddress,
            amount: amountWei,
            timestamp: Date.now()
        });

        // Update auction info off-chain
        await OffchainAuction.findOneAndUpdate(
            { auctionId },
            {
                highestBid: amountWei,
                highestBidder: user.ethAddress
            }
        );

        return res.json({
            success: true,
            txHash: receipt.transactionHash
        });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: err.message });
    }
});

// ========== API LẤY TẤT CẢ AUCTION ==========  
router.get("/all", async (req, res) => {
    const auctions = await OffchainAuction.find().sort({ createdAt: -1 });
    return res.json(auctions);
});

// ========== API LẤY CHI TIẾT AUCTION + LỊCH SỬ BID ==========  
router.get("/:id", async (req, res) => {
    const auction = await OffchainAuction.findOne({ auctionId: req.params.id });
    if (!auction) return res.status(404).json({ error: "Auction not found" });

    const bids = await BidHistory.find({ auctionId: req.params.id })
        .sort({ timestamp: -1 });

    return res.json({
        auction,
        bidHistory: bids
    });
});

module.exports = router;
