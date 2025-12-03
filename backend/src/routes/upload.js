const express = require("express");
const router = express.Router();
const { authMiddleware } = require("../middleware/auth");
const upload = require("../middleware/upload");
const cloudinary = require("../config/cloudinary");
const { uploadFileToPinata } = require("../services/pinata.service");
const fs = require("fs");

// ========== AVATAR APIs ==========

// 1) Upload avatar -> Cloudinary (returns URL only, deprecated - use /avatar/update instead)
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

    // Send URL to frontend, then frontend calls PUT /user/me with this avatar URL
    return res.json({ url: result.secure_url });
  } catch (err) {
    console.error("Avatar upload error:", err);
    return res.status(500).json({ error: err.message });
  }
});

// 1.5) 🎯 RECOMMENDED: Upload avatar AND update profile in ONE call
// Frontend can just call this API with file -> Done!
router.post("/avatar/update", authMiddleware, upload.single("file"), async (req, res) => {
  try {
    // Validate file exists
    if (!req.file) {
      console.error("No file in request");
      return res.status(400).json({ error: "File required" });
    }

    const filePath = req.file.path;
    console.log("Uploading file to Cloudinary:", filePath);

    // Upload to Cloudinary
    const result = await cloudinary.uploader.upload(filePath, {
      folder: "avatars",
      transformation: [{ width: 300, height: 300, crop: "fill" }]
    });

    console.log("Cloudinary upload successful:", result.secure_url);

    // Remove local file
    try {
      fs.unlinkSync(filePath);
    } catch (unlinkErr) {
      console.error("Error removing temp file:", unlinkErr);
    }

    // Auto-update user profile with new avatar URL
    const User = require("../models/User");
    const updatedUser = await User.findByIdAndUpdate(
      req.user.id,
      { $set: { avatar: result.secure_url } },
      { new: true, runValidators: true }
    ).select("-password_hash -encrypted_private_key");

    if (!updatedUser) {
      return res.status(404).json({ error: "User not found" });
    }

    console.log("User avatar updated successfully");

    // Return complete user object with new avatar
    return res.json({
      success: true,
      message: "Avatar updated successfully",
      avatar_url: result.secure_url,
      user: updatedUser
    });
  } catch (err) {
    console.error("Avatar update error:", err);
    return res.status(500).json({
      error: "Avatar upload failed",
      details: err.message
    });
  }
});

// ========== PRODUCT IMAGE APIs (IPFS) ==========

// 2) Upload single product image -> Pinata (IPFS)
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
    // Frontend should use gatewayUrl or ipfsUri in POST /auction/create (images field)
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

// 2.5) 🎯 RECOMMENDED: Upload MULTIPLE product images at once
// Frontend can upload all images in one API call -> Get array of URLs!
router.post("/ipfs/multiple", authMiddleware, upload.array("files", 10), async (req, res) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ error: "At least one file required" });
    }

    const uploadResults = [];
    const errors = [];

    // Upload each file to IPFS
    for (const file of req.files) {
      try {
        const filePath = file.path;

        const pinResult = await uploadFileToPinata(filePath, {
          pinataMetadata: {
            name: file.originalname
          }
        });

        const cid = pinResult.IpfsHash;
        uploadResults.push({
          filename: file.originalname,
          cid,
          ipfsUri: `ipfs://${cid}`,
          gatewayUrl: `https://gateway.pinata.cloud/ipfs/${cid}`
        });

        // Remove local file
        fs.unlinkSync(filePath);
      } catch (err) {
        errors.push({
          filename: file.originalname,
          error: err.message
        });
        // Still try to remove the file
        try { fs.unlinkSync(file.path); } catch { }
      }
    }

    // Return results
    return res.json({
      success: true,
      uploaded: uploadResults.length,
      failed: errors.length,
      images: uploadResults.map(r => r.gatewayUrl), // Array of URLs ready for auction creation
      details: uploadResults,
      errors: errors.length > 0 ? errors : undefined
    });

  } catch (err) {
    console.error("Multiple IPFS upload error:", err);
    return res.status(500).json({ error: err.message });
  }
});

module.exports = router;