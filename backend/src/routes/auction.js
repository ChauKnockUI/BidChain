const express = require("express");
const router = express.Router();
const User = require("../models/User");
const { ethers } = require("ethers");
const { decrypt } = require("../utils/crypto");
const { authMiddleware } = require("../middleware/auth");
const { provider, contract } = require("../blockchain/contract");
const OffchainAuction = require("../models/OffchainAuction");
const { body, param, validationResult } = require("express-validator");
const { validateBid } = require("../middleware/bid");

require("dotenv").config();

// ========== API LẤY SỐ DƯ ==========
router.get("/wallet/balance", authMiddleware, async (req, res) => {
    // req.user được gắn vào từ authMiddleware
    const user = await User.findById(req.user.id);
    if (!user) return res.status(404).json({ error: "User not found" });

    const balance = await provider.getBalance(user.ethAddress);

    const balanceEther = ethers.utils.formatEther(balance);

    return res.json({
        address: user.ethAddress,
        balance: balance.toString(),
        balanceEther: balanceEther
    });
});

// ========== API TẠO PHIÊN ĐẤU GIÁ ==========
router.post("/create", authMiddleware,[
    body("startingPriceWei").isString().notEmpty(),
    body("durationSeconds").isNumeric(),
    body("metadataUrl").isURL().optional(), 
  ], async (req, res) => {
    try {
        const { startingPriceWei, durationSeconds, metadataUrl } = req.body;

        // req.user được gắn vào từ authMiddleware
        const user = await User.findById(req.user.id);
        if (!user) return res.status(404).json({ error: "user not found" });

        const decryptedPrivateKey = decrypt(
            user.encryptedPrivateKey,
            process.env.MASTER_KEY
        );

        const wallet = new ethers.Wallet(decryptedPrivateKey, provider);


        // Kết nối wallet (signer) vào contract để có thể gửi giao dịch
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

        return res.json({
            txHash: receipt.transactionHash,
            auctionId: auctionId
        });
} catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

// ========== API BID ==========
router.post(
  "/bid",
  authMiddleware,
  validateBid,
  async (req, res) => {
    try {
      const { auctionId, amountWei } = req.body;

      // === BigInt an toàn ===
      let auctionIdBigInt, amountWeiBigInt;
      try {
        auctionIdBigInt = BigInt(auctionId);
        amountWeiBigInt = BigInt(amountWei);
      } catch {
        return res.status(400).json({ error: "Invalid number format" });
      }

      const user = await User.findById(req.user.id);
      if (!user) return res.status(404).json({ error: "User not found" });

      const privateKey = decrypt(user.encryptedPrivateKey, process.env.MASTER_KEY);
      const wallet = new ethers.Wallet(privateKey, provider);

      // === Kiểm tra auction ===
      const auction = await contract.auctions(auctionIdBigInt);
      const now = Math.floor(Date.now() / 1000);

      if (auction.seller.toLowerCase() === wallet.address.toLowerCase()) {
        return res.status(400).json({ error: "Cannot bid on your own auction" });
      }
      if (now >= auction.endTime.toNumber()) {
        return res.status(400).json({ error: "Auction has ended" });
      }
      if (auction.ended) {
        return res.status(400).json({ error: "Auction already finalized" });
      }

      // === Kiểm tra số dư ===
      const balance = await provider.getBalance(wallet.address);
      const GAS_RESERVE = ethers.utils.parseUnits("0.01", "ether");
      if (balance < amountWeiBigInt + GAS_RESERVE) {
        return res.status(400).json({
          error: "Insufficient balance (including gas)",
          balance: ethers.utils.formatEther(balance),
          required: ethers.utils.formatEther(amountWeiBigInt + GAS_RESERVE),
        });
      }

      // === Gửi tx ===
      const tx = await contract.connect(wallet).bid(auctionIdBigInt, {
        value: amountWeiBigInt,
        gasLimit: 200000,
      });

      const receipt = await tx.wait();

      return res.json({
        success: true,
        txHash: receipt.transactionHash,
      });
    } catch (err) {
      console.error("Bid error:", err);
      const reason = err.reason || err.message || "Transaction failed";
      return res.status(500).json({ error: reason });
    }
  }
);
router.post(
  "/:id/end", // :id là auctionId
  authMiddleware,
  [param("id").isNumeric()],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    try {
      const auctionId = BigInt(req.params.id);
      // Bất kỳ ai cũng có thể gọi kết thúc, nhưng chúng ta hãy
      // dùng ví của người bán (hoặc 1 ví hệ thống) để trả gas
      const user = await User.findById(req.user.id);
      if (!user) return res.status(404).json({ error: "User not found" });
const privateKey = decrypt(user.encryptedPrivateKey, process.env.MASTER_KEY);
      const wallet = new ethers.Wallet(privateKey, provider);

      // (Nên kiểm tra xem đã hết giờ chưa ở đây trước khi gửi)

      const tx = await contract.connect(wallet).endAuction(auctionId);
      const receipt = await tx.wait();

      return res.json({
        success: true,
        message: "Auction ended successfully",
        txHash: receipt.transactionHash,
      });
    } catch (err) {
      console.error(err);
      const reason = err.reason || err.message;
      return res.status(500).json({ error: reason });
    }
  }
);

// ========== API RÚT TIỀN (MỚI) ==========
router.post(
  "/wallet/withdraw",
  authMiddleware,
  [
    body("toAddress").isEthereumAddress().withMessage("Invalid Ethereum address"),
    body("amountEther").isString().notEmpty().withMessage("Amount is required"),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    try {
      const { toAddress, amountEther } = req.body;
      const user = await User.findById(req.user.id);
      if (!user) return res.status(404).json({ error: "User not found" });

      const privateKey = decrypt(user.encryptedPrivateKey, process.env.MASTER_KEY);
      const wallet = new ethers.Wallet(privateKey, provider);

      const amountWei = ethers.utils.parseUnits(amountEther, "ether");
      const balance = await provider.getBalance(wallet.address);
      const { gasPrice } = await provider.getFeeData();

      // Ước lượng gas (21000 là gas limit chuẩn)
      const gasLimit = 21000n; // Dùng BigInt
      const gasCost = gasLimit * gasPrice;
      
      if (balance < (amountWei + gasCost)) {
         return res.status(400).json({ error: "Insufficient funds for withdrawal + gas" });
      }
      
      const tx = await wallet.sendTransaction({
          to: toAddress,
          value: amountWei
      });
      
      await tx.wait();
      
      return res.json({ success: true, txHash: tx.hash, amountSent: amountEther });
      
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: err.message });
    }
  }
);


// ========== API LẤY DỮ LIỆU OFF-CHAIN (MỚI) ==========

// Lấy tất cả phiên đấu giá (còn hoạt động)
router.get("/all", async (req, res) => {
  try {
    const auctions = await OffchainAuction.find({ ended: false })
                                          .sort({ endTime: 1 }); // Sắp hết hạn trước
    res.json(auctions);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Lấy chi tiết 1 phiên đấu giá
router.get("/:id", [param("id").isNumeric()], async (req, res) => {
    try {
        const auction = await OffchainAuction.findOne({ auctionId: req.params.id });
        if (!auction) {
return res.status(404).json({ error: "Auction not found" });
        }
        res.json(auction);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;