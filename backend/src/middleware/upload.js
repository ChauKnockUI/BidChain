const multer = require("multer");
const path = require("path");
const fs = require("fs");

// Store files temporarily in /tmp/uploads (create folder if missing)
const TMP_DIR = path.join(__dirname, "../../tmp/uploads");
fs.mkdirSync(TMP_DIR, { recursive: true });

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, TMP_DIR);
  },
  filename: function (req, file, cb) {
    const unique = Date.now() + "-" + Math.round(Math.random()*1e9);
    cb(null, unique + path.extname(file.originalname));
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 20 * 1024 * 1024 }, // 5MB limit 
});

module.exports = upload;