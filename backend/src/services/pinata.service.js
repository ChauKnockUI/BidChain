const pinataSDK = require("@pinata/sdk");
require("dotenv").config();

const pinata = new pinataSDK(process.env.PINATA_API_KEY, process.env.PINATA_API_SECRET);

// Upload local file path
async function uploadFileToPinata(filePath, options = {}) {
    // filePath: path to local file (multer stores to tmp)
    try {
        const result = await pinata.pinFromFS(filePath, options);
        // result = { IpfsHash, PinSize, Timestamp }
        return result;
    } catch (err) {
        throw err;
    }
}

module.exports = { uploadFileToPinata };