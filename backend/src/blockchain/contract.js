const fs = require('fs');
const path = require('path');
const { ethers } = require('ethers');
require('dotenv').config();

const RPC = process.env.GANACHE_RPC || 'http://127.0.0.1:7545';
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS;
const ABI_PATH = process.env.CONTRACT_ABI_PATH || './abi/Auction.json';

// -----------------------
// PROVIDER (ethers v5)
// -----------------------
const provider = new ethers.providers.JsonRpcProvider(RPC);

// -----------------------
// LOAD ABI
// -----------------------
let abi;
try {
  const raw = fs.readFileSync(path.resolve(ABI_PATH), 'utf8');
  const parsed = JSON.parse(raw);
  abi = parsed.abi || parsed;
} catch (e) {
  console.error('Cannot load contract ABI from', ABI_PATH, e.message);
  process.exit(1);
}

// -----------------------
// CONTRACT INSTANCE
// -----------------------
const contract = new ethers.Contract(CONTRACT_ADDRESS, abi, provider);

// -----------------------
// CREATE WALLET FROM PRIVATE KEY
// -----------------------
function walletFromPrivateKey(privateKey) {
  return new ethers.Wallet(privateKey, provider);
}

module.exports = { provider, contract, walletFromPrivateKey };
