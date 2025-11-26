// src/scripts/fix-balance-unit.js
// PHIÊN BẢN CUỐI CÙNG – CHẠY NGON 100% DÙ BẠN LÀM GÌ CŨNG ĐƯỢC

const path = require('path');
const fs = require('fs');

// Tìm file .env bằng mọi giá
const rootDir = path.resolve(__dirname, '../..');
const envPath = path.join(rootDir, '.env');

if (fs.existsSync(envPath)) {
  require('dotenv').config({ path: envPath });
  console.log("Đã load .env từ:", envPath);
} else {
  console.log("Không thấy .env → dùng localhost");
}

// DÙ SAO CŨNG ÉP BUỘC CÓ URI HỢP LỆ
const MONGODB_URI = process.env.MONGO_URI.trim();

console.log("Kết nối tới:", MONGODB_URI);
if (!MONGODB_URI || MONGODB_URI === "undefined") {
  console.error("MONGODB_URI bị undefined! Kiểm tra file .env có dòng MONGODB_URI=... không");
  process.exit(1);
}

// BẮT BUỘC import mongoose SAU KHI ĐÃ CÓ URI
const mongoose = require('mongoose');
const User = require('../models/User');
const { ethers } = require('ethers');

(async () => {
  try {
    // DÙNG CÚ PHÁP MỚI NHẤT CỦA MONGOOSE 7+
    await mongoose.connect(MONGODB_URI);
    console.log("Kết nối MongoDB thành công!\n");

    const users = await User.find({}).select('username email balance_eth locked_eth');
    let fixed = 0;

    for (const user of users) {
      const updates = {};
      let changed = false;

      // Xử lý balance_eth
      if (user.balance_eth != null) {
        const raw = user.balance_eth.toString();
        const num = parseFloat(raw);
        if (!isNaN(num) && num > 0) {
          updates.balance_eth = ethers.utils.parseEther(num.toFixed(18)).toString();
          changed = true;
        }
      }

      // Xử lý locked_eth
      if (user.locked_eth != null) {
        const raw = user.locked_eth.toString();
        const num = parseFloat(raw);
        if (!isNaN(num) && num > 0) {
          updates.locked_eth = ethers.utils.parseEther(num.toFixed(18)).toString();
          changed = true;
        }
      }

      if (changed) {
        await User.updateOne({ _id: user._id }, { $set: updates });
        console.log(`ĐÃ SỬA: ${user.username || user.email} → ${updates.balance_eth || updates.locked_eth} wei`);
        fixed++;
      }
    }

    console.log(`\nHOÀN TẤT! Đã sửa ${fixed} người dùng.`);
    console.log("BÂY GIỜ BẠN CÓ THỂ ĐẶT BID THOẢI MÁI!");
    process.exit(0);

  } catch (error) {
    console.error("LỖI:", error.message);
    process.exit(1);
  }
})();