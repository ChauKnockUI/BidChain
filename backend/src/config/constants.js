// Exchange Rate Configuration
const EXCHANGE_RATE = {
  ETH_TO_VND: 50000000, // 1 ETH = 50.000.000 VND
  VND_TO_ETH: 0.00000002, // 1 VND = 0.00000002 ETH
};

// Wei conversion helpers
const WEI_PER_ETH = '1000000000000000000'; // 10^18

// EIP-712 Domain Separator for signing
const EIP712_DOMAIN = {
  name: 'BidChain',
  version: '1.0',
  chainId: 1337, // Local Hardhat network
  verifyingContract: process.env.CONTRACT_ADDRESS || '0x0000000000000000000000000000000000000000'
};

// EIP-712 Bid Message Type
const BID_MESSAGE_TYPE = {
  Bid: [
    { name: 'auctionId', type: 'string' },
    { name: 'amount', type: 'uint256' },
    { name: 'nonce', type: 'uint256' },
    { name: 'timestamp', type: 'uint256' }
  ]
};

// Auction Statuses
const AUCTION_STATUS = {
  PENDING_APPROVAL: 'PENDING_APPROVAL',
  APPROVED: 'APPROVED',
  REJECTED: 'REJECTED',
  DEPLOYING: 'DEPLOYING',
  ACTIVE: 'ACTIVE',
  ENDED: 'ENDED',
  SETTLED: 'SETTLED'
};

// Bid Statuses
const BID_STATUS = {
  VALID: 'VALID',
  INVALID: 'INVALID',
  OUTBID: 'OUTBID',
  WINNING: 'WINNING'
};

// User Roles
const USER_ROLES = {
  ADMIN: 'ADMIN',
  MANAGER: 'MANAGER',
  SELLER: 'SELLER',
  BIDDER: 'BIDDER'
};

// User Statuses
const USER_STATUS = {
  ACTIVE: 'ACTIVE',
  BANNED: 'BANNED'
};

// Transaction Types
const TRANSACTION_TYPES = {
  DEPOSIT: 'DEPOSIT',
  WITHDRAW: 'WITHDRAW',
  LISTING_FEE: 'LISTING_FEE',
  AUCTION_SETTLEMENT: 'AUCTION_SETTLEMENT'
};

// Notification Types
const NOTIFICATION_TYPES = {
  AUCTION_PENDING_APPROVAL: 'AUCTION_PENDING_APPROVAL',
  AUCTION_APPROVED: 'AUCTION_APPROVED',
  AUCTION_REJECTED: 'AUCTION_REJECTED',
  AUCTION_STARTED: 'AUCTION_STARTED',
  OUTBID: 'OUTBID',
  WON_AUCTION: 'WON_AUCTION'
};

module.exports = {
  EXCHANGE_RATE,
  WEI_PER_ETH,
  EIP712_DOMAIN,
  BID_MESSAGE_TYPE,
  AUCTION_STATUS,
  BID_STATUS,
  USER_ROLES,
  USER_STATUS,
  TRANSACTION_TYPES,
  NOTIFICATION_TYPES
};
