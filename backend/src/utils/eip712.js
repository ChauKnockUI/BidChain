const { ethers } = require('ethers');
const { EIP712_DOMAIN, BID_MESSAGE_TYPE } = require('../config/constants');

/**
 * Create EIP-712 typed data for bid signing
 * @param {string} auctionId - Auction ID
 * @param {string} amountWei - Bid amount in Wei
 * @param {number} nonce - User nonce
 * @param {number} timestamp - Current timestamp
 * @returns {object} - Typed data object
 */
function createBidTypedData(auctionId, amountWei, nonce, timestamp) {
  return {
    types: {
      EIP712Domain: [
        { name: 'name', type: 'string' },
        { name: 'version', type: 'string' },
        { name: 'chainId', type: 'uint256' },
        { name: 'verifyingContract', type: 'address' }
      ],
      ...BID_MESSAGE_TYPE
    },
    primaryType: 'Bid',
    domain: EIP712_DOMAIN,
    message: {
      auctionId,
      amount: amountWei,
      nonce,
      timestamp
    }
  };
}

/**
 * Verify EIP-712 signature for bid
 * @param {string} signature - The signature to verify
 * @param {string} auctionId - Auction ID
 * @param {string} amountWei - Bid amount in Wei
 * @param {number} nonce - User nonce
 * @param {number} timestamp - Timestamp when signed
 * @param {string} signerAddress - Expected signer address
 * @returns {boolean} - Whether signature is valid
 */
function verifyBidSignature(signature, auctionId, amountWei, nonce, timestamp, signerAddress) {
  try {
    const typedData = createBidTypedData(auctionId, amountWei, nonce, timestamp);
    const recoveredAddress = ethers.utils.verifyTypedData(
      typedData.domain,
      { Bid: typedData.types.Bid },
      typedData.message,
      signature
    );
    return recoveredAddress.toLowerCase() === signerAddress.toLowerCase();
  } catch (error) {
    console.error('Error verifying signature:', error);
    return false;
  }
}

/**
 * Sign bid data with EIP-712
 * @param {string} privateKey - Private key for signing
 * @param {string} auctionId - Auction ID
 * @param {string} amountWei - Bid amount in Wei
 * @param {number} nonce - User nonce
 * @param {number} timestamp - Current timestamp
 * @returns {string} - The signature
 */
async function signBid(privateKey, auctionId, amountWei, nonce, timestamp) {
  const wallet = new ethers.Wallet(privateKey);
  const typedData = createBidTypedData(auctionId, amountWei, nonce, timestamp);

  const signature = await wallet._signTypedData(
    typedData.domain,
    { Bid: typedData.types.Bid },
    typedData.message
  );

  return signature;
}

module.exports = {
  createBidTypedData,
  verifyBidSignature,
  signBid
};
