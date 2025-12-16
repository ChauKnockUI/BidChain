// src/blockchain/wallet-contract.js
// BidChainWallet contract integration module

const fs = require('fs');
const path = require('path');
const { ethers } = require('ethers');
require('dotenv').config();

const RPC = process.env.GANACHE_RPC || 'http://127.0.0.1:7545';
const WALLET_CONTRACT_ADDRESS = process.env.WALLET_CONTRACT_ADDRESS;
const WALLET_ABI_PATH = process.env.WALLET_ABI_PATH || './abi/BidChainWallet.json';

// Provider
const provider = new ethers.providers.JsonRpcProvider(RPC);

// Load ABI
let walletAbi;
try {
    const raw = fs.readFileSync(path.resolve(WALLET_ABI_PATH), 'utf8');
    const parsed = JSON.parse(raw);
    walletAbi = parsed.abi || parsed;
} catch (e) {
    console.error('Cannot load BidChainWallet ABI from', WALLET_ABI_PATH, e.message);
    walletAbi = null;
}

// Contract instance (read-only by default)
let walletContract = null;
if (WALLET_CONTRACT_ADDRESS && walletAbi) {
    walletContract = new ethers.Contract(WALLET_CONTRACT_ADDRESS, walletAbi, provider);
    console.log('✅ BidChainWallet contract loaded at:', WALLET_CONTRACT_ADDRESS);
} else {
    console.warn('⚠️ BidChainWallet not configured - on-chain balance disabled');
}

// Create wallet from private key for signing transactions
function getOperatorWallet() {
    const privateKey = process.env.DEPLOYER_PRIVATE_KEY;
    if (!privateKey) {
        throw new Error('Missing DEPLOYER_PRIVATE_KEY in .env');
    }
    return new ethers.Wallet(privateKey, provider);
}

// ========== ON-CHAIN BALANCE FUNCTIONS ==========

/**
 * Get user balance from smart contract
 * @param {string} userAddress - User wallet address
 * @returns {Promise<{total: string, locked: string, available: string}>} Balance in wei
 */
async function getOnChainBalance(userAddress) {
    if (!walletContract) {
        throw new Error('Wallet contract not configured');
    }

    const [total, locked, available] = await walletContract.getBalanceInfo(userAddress);

    return {
        total: total.toString(),
        locked: locked.toString(),
        available: available.toString()
    };
}

/**
 * Deposit ETH for a user (after MoMo payment)
 * @param {string} userAddress - User wallet address
 * @param {string} amountWei - Amount in wei
 * @returns {Promise<{txHash: string, blockNumber: number}>}
 */
async function depositForUser(userAddress, amountWei) {
    if (!walletContract) {
        throw new Error('Wallet contract not configured');
    }

    const operator = getOperatorWallet();
    const contractWithSigner = walletContract.connect(operator);

    console.log(`💰 Depositing ${amountWei} wei for ${userAddress}...`);

    const tx = await contractWithSigner.depositFor(userAddress, {
        value: ethers.BigNumber.from(amountWei)
    });

    const receipt = await tx.wait();

    console.log(`✅ Deposit successful! TX: ${receipt.transactionHash}`);

    return {
        txHash: receipt.transactionHash,
        blockNumber: receipt.blockNumber
    };
}

/**
 * Lock user balance for a bid
 * @param {string} userAddress - User wallet address
 * @param {number} auctionId - Auction blockchain ID
 * @param {string} amountWei - Amount to lock in wei
 * @returns {Promise<{txHash: string, blockNumber: number}>}
 */
async function lockUserBalance(userAddress, auctionId, amountWei) {
    if (!walletContract) {
        throw new Error('Wallet contract not configured');
    }

    const operator = getOperatorWallet();
    const contractWithSigner = walletContract.connect(operator);

    console.log(`🔒 Locking ${amountWei} wei for user ${userAddress} on auction ${auctionId}...`);

    const tx = await contractWithSigner.lockBalance(
        userAddress,
        auctionId,
        ethers.BigNumber.from(amountWei)
    );

    const receipt = await tx.wait();

    console.log(`✅ Lock successful! TX: ${receipt.transactionHash}`);

    return {
        txHash: receipt.transactionHash,
        blockNumber: receipt.blockNumber
    };
}

/**
 * Unlock user balance (when outbid)
 * @param {string} userAddress - User wallet address
 * @param {number} auctionId - Auction blockchain ID
 * @param {string} amountWei - Amount to unlock in wei
 * @returns {Promise<{txHash: string, blockNumber: number}>}
 */
async function unlockUserBalance(userAddress, auctionId, amountWei) {
    if (!walletContract) {
        throw new Error('Wallet contract not configured');
    }

    const operator = getOperatorWallet();
    const contractWithSigner = walletContract.connect(operator);

    console.log(`🔓 Unlocking ${amountWei} wei for user ${userAddress} on auction ${auctionId}...`);

    const tx = await contractWithSigner.unlockBalance(
        userAddress,
        auctionId,
        ethers.BigNumber.from(amountWei)
    );

    const receipt = await tx.wait();

    console.log(`✅ Unlock successful! TX: ${receipt.transactionHash}`);

    return {
        txHash: receipt.transactionHash,
        blockNumber: receipt.blockNumber
    };
}

/**
 * Settle bid - transfer from winner to seller
 * @param {string} winnerAddress - Winner wallet address
 * @param {string} sellerAddress - Seller wallet address
 * @param {number} auctionId - Auction blockchain ID  
 * @param {string} amountWei - Settlement amount in wei
 * @returns {Promise<{txHash: string, blockNumber: number}>}
 */
async function settleBid(winnerAddress, sellerAddress, auctionId, amountWei) {
    if (!walletContract) {
        throw new Error('Wallet contract not configured');
    }

    const operator = getOperatorWallet();
    const contractWithSigner = walletContract.connect(operator);

    console.log(`💸 Settling bid: ${amountWei} wei from ${winnerAddress} to ${sellerAddress}...`);

    const tx = await contractWithSigner.settleBid(
        winnerAddress,
        sellerAddress,
        auctionId,
        ethers.BigNumber.from(amountWei)
    );

    const receipt = await tx.wait();

    console.log(`✅ Settlement successful! TX: ${receipt.transactionHash}`);

    return {
        txHash: receipt.transactionHash,
        blockNumber: receipt.blockNumber
    };
}

/**
 * Check if wallet contract is available
 * @returns {boolean}
 */
function isWalletContractAvailable() {
    return walletContract !== null;
}

module.exports = {
    walletContract,
    provider,
    getOnChainBalance,
    depositForUser,
    lockUserBalance,
    unlockUserBalance,
    settleBid,
    isWalletContractAvailable,
    WALLET_CONTRACT_ADDRESS
};
