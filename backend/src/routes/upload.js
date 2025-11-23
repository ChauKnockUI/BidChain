const express = require("express");
const router = express.Router();
const { authMiddleware } = require("../middleware/auth");
const upload = require("../middleware/upload");
const cloudinary = require("../config/cloudinary");
const { uploadFileToPinata } = require("../services/pinata.service");
const fs = require("fs");

// 1) Upload avatar -> Cloudinary
router.post("/avatar", authMiddleware, upload.single("file"), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ error: "File required" });
    const filePath = req.file.path;

    const result = await cloudinary.uploader.upload(filePath, {
      folder: "avatars",
      transformation: [{ width: 300, height: 300, crop: "fill" }]
    });

    // remove local file
    fs.unlinkSync(filePath);

    // save result.secure_url into user model in FE or you can persist here
    return res.json({ url: result.secure_url });
  } catch (err) {
    console.error("Avatar upload error:", err);
    return res.status(500).json({ error: err.message });
  }
});

// 2) Upload product image -> Pinata (IPFS)
router.post("/ipfs", authMiddleware, upload.single("file"), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ error: "File required" });
    const filePath = req.file.path;

    const pinResult = await uploadFileToPinata(filePath, {
      // optional pin options, metadata etc
    });

    // remove local file
    fs.unlinkSync(filePath);

    // pinResult.IpfsHash is the CID
    const cid = pinResult.IpfsHash;
    // Return both ipfs uri and gateway url for convenience
    return res.json({
      cid,
      ipfsUri: `ipfs://${cid}`,
      gatewayUrl: `https://gateway.pinata.cloud/ipfs/${cid}`
    });
  } catch (err) {
    console.error("IPFS upload error:", err);
    return res.status(500).json({ error: err.message });
  }
});

module.exports = router;