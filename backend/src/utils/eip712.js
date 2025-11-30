// src/utils/eip712.js
const { ethers } = require('ethers');
const { decrypt } = require('./crypto');
require('dotenv').config();

/**
 * EIP-712 Domain for BidChain
 */
const DOMAIN = {
  name: 'BidChain',
  version: '1.0',
  chainId: 1337, // Ganache local
  verifyingContract: process.env.CONTRACT_ADDRESS
};

/**
 * Bid type definition for EIP-712
 */
const BID_TYPES = {
  Bid: [
    { name: 'auctionId', type: 'string' },
    { name: 'amount', type: 'uint256' },
    { name: 'nonce', type: 'uint256' },
    { name: 'timestamp', type: 'uint256' }
  ]
};

/**
 * Sign a bid using EIP-712
 * @param {Object} user - User object with encrypted_private_key
 * @param {string} auctionId - Auction ID
 * @param {string} amountWei - Bid amount in Wei
 * @param {number} nonce - User nonce
 * @param {number} timestamp - Current timestamp
 * @returns {Promise<string>} Signature
 */
async function signBid(user, auctionId, amountWei, nonce, timestamp) {
  try {
    console.log(`Signing bid - User wallet: ${user.wallet_address}`);
    console.log(`Has encrypted_private_key: ${!!user.encrypted_private_key}`);

    // Decrypt private key with MASTER_KEY
    const privateKey = decrypt(user.encrypted_private_key, process.env.MASTER_KEY);
    const wallet = new ethers.Wallet(privateKey);

    // Create bid data
    const bidData = {
      auctionId: auctionId,
      amount: ethers.BigNumber.from(amountWei),
      nonce: nonce,
      timestamp: timestamp
    };

    // Sign with EIP-712
    const signature = await wallet._signTypedData(
      DOMAIN,
      BID_TYPES,
      bidData
    );

    console.log(`Bid signed successfully for auction ${auctionId}`);
    return signature;

  } catch (error) {
    console.error('Error signing bid:', error);
    throw new Error('Failed to sign bid: ' + error.message);
  }
}

/**
 * Verify bid signature (for testing)
 * @param {Object} params - Verification parameters
 * @returns {Promise<string>} Recovered signer address
 */
async function verifyBidSignature({ auctionId, amountWei, nonce, timestamp, signature }) {
  try {
    const bidData = {
      auctionId: auctionId,
      amount: ethers.BigNumber.from(amountWei),
      nonce: nonce,
      timestamp: timestamp
    };

    const recoveredAddress = ethers.utils.verifyTypedData(
      DOMAIN,
      BID_TYPES,
      bidData,
      signature
    );

    return recoveredAddress;
  } catch (error) {
    console.error('Error verifying signature:', error);
    throw error;
  }
}

module.exports = {
  signBid,
  verifyBidSignature
};
