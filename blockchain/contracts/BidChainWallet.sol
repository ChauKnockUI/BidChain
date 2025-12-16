// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title BidChainWallet
 * @notice Central wallet contract for on-chain balance management
 * @dev Users deposit ETH, which can be locked/unlocked for bidding
 * 
 * Flow:
 * 1. User deposits ETH → balance increases
 * 2. User places bid → amount is locked (balance stays, locked increases)
 * 3. User is outbid → amount is unlocked
 * 4. User wins auction → locked amount transfers to seller
 * 5. User withdraws → available balance (balance - locked) sent to user
 */
contract BidChainWallet is Ownable, ReentrancyGuard {
    
    // ========== STATE VARIABLES ==========
    
    // User balances (total deposited ETH in wei)
    mapping(address => uint256) public balances;
    
    // User locked amounts (ETH locked for active bids in wei)
    mapping(address => uint256) public lockedBalances;
    
    // Authorized operators (backend addresses that can lock/unlock/transfer)
    mapping(address => bool) public operators;
    
    // ========== EVENTS ==========
    
    event Deposited(
        address indexed user,
        uint256 amount,
        uint256 newBalance,
        uint256 timestamp
    );
    
    event Withdrawn(
        address indexed user,
        uint256 amount,
        uint256 newBalance,
        uint256 timestamp
    );
    
    event BalanceLocked(
        address indexed user,
        uint256 auctionId,
        uint256 amount,
        uint256 totalLocked,
        uint256 timestamp
    );
    
    event BalanceUnlocked(
        address indexed user,
        uint256 auctionId,
        uint256 amount,
        uint256 totalLocked,
        uint256 timestamp
    );
    
    event BidSettled(
        address indexed winner,
        address indexed seller,
        uint256 auctionId,
        uint256 amount,
        uint256 timestamp
    );
    
    event OperatorAdded(address indexed operator);
    event OperatorRemoved(address indexed operator);
    
    // ========== MODIFIERS ==========
    
    modifier onlyOperator() {
        require(operators[msg.sender] || msg.sender == owner(), "Not authorized operator");
        _;
    }
    
    // ========== CONSTRUCTOR ==========
    
    constructor() Ownable(msg.sender) {
        // Owner is automatically an operator
        operators[msg.sender] = true;
    }
    
    // ========== OPERATOR MANAGEMENT ==========
    
    function addOperator(address _operator) external onlyOwner {
        require(_operator != address(0), "Invalid address");
        operators[_operator] = true;
        emit OperatorAdded(_operator);
    }
    
    function removeOperator(address _operator) external onlyOwner {
        operators[_operator] = false;
        emit OperatorRemoved(_operator);
    }
    
    // ========== USER FUNCTIONS ==========
    
    /**
     * @notice Deposit ETH into the wallet
     * @dev User sends ETH directly to this function
     */
    function deposit() external payable nonReentrant {
        require(msg.value > 0, "Must deposit positive amount");
        
        balances[msg.sender] += msg.value;
        
        emit Deposited(
            msg.sender,
            msg.value,
            balances[msg.sender],
            block.timestamp
        );
    }
    
    /**
     * @notice Deposit ETH for a specific user (admin deposits after MoMo payment)
     * @param _user User address to credit
     */
    function depositFor(address _user) external payable onlyOperator nonReentrant {
        require(_user != address(0), "Invalid user address");
        require(msg.value > 0, "Must deposit positive amount");
        
        balances[_user] += msg.value;
        
        emit Deposited(
            _user,
            msg.value,
            balances[_user],
            block.timestamp
        );
    }
    
    /**
     * @notice Withdraw available (unlocked) ETH
     * @param _amount Amount to withdraw in wei
     */
    function withdraw(uint256 _amount) external nonReentrant {
        uint256 available = balances[msg.sender] - lockedBalances[msg.sender];
        require(_amount > 0, "Must withdraw positive amount");
        require(_amount <= available, "Insufficient available balance");
        
        balances[msg.sender] -= _amount;
        
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "ETH transfer failed");
        
        emit Withdrawn(
            msg.sender,
            _amount,
            balances[msg.sender],
            block.timestamp
        );
    }
    
    // ========== OPERATOR FUNCTIONS (Backend calls) ==========
    
    /**
     * @notice Lock user balance for a bid
     * @param _user User address
     * @param _auctionId Auction ID (for event logging)
     * @param _amount Amount to lock in wei
     */
    function lockBalance(
        address _user,
        uint256 _auctionId,
        uint256 _amount
    ) external onlyOperator nonReentrant {
        uint256 available = balances[_user] - lockedBalances[_user];
        require(_amount <= available, "Insufficient available balance to lock");
        
        lockedBalances[_user] += _amount;
        
        emit BalanceLocked(
            _user,
            _auctionId,
            _amount,
            lockedBalances[_user],
            block.timestamp
        );
    }
    
    /**
     * @notice Unlock user balance (when outbid or auction cancelled)
     * @param _user User address
     * @param _auctionId Auction ID (for event logging)
     * @param _amount Amount to unlock in wei
     */
    function unlockBalance(
        address _user,
        uint256 _auctionId,
        uint256 _amount
    ) external onlyOperator nonReentrant {
        require(lockedBalances[_user] >= _amount, "Cannot unlock more than locked");
        
        lockedBalances[_user] -= _amount;
        
        emit BalanceUnlocked(
            _user,
            _auctionId,
            _amount,
            lockedBalances[_user],
            block.timestamp
        );
    }
    
    /**
     * @notice Settle a bid - transfer locked funds from winner to seller
     * @param _winner Winner address
     * @param _seller Seller address
     * @param _auctionId Auction ID
     * @param _amount Settlement amount in wei
     */
    function settleBid(
        address _winner,
        address _seller,
        uint256 _auctionId,
        uint256 _amount
    ) external onlyOperator nonReentrant {
        require(_winner != address(0), "Invalid winner");
        require(_seller != address(0), "Invalid seller");
        require(lockedBalances[_winner] >= _amount, "Insufficient locked balance");
        require(balances[_winner] >= _amount, "Insufficient total balance");
        
        // Decrease winner's balance and locked
        balances[_winner] -= _amount;
        lockedBalances[_winner] -= _amount;
        
        // Increase seller's balance (available immediately)
        balances[_seller] += _amount;
        
        emit BidSettled(
            _winner,
            _seller,
            _auctionId,
            _amount,
            block.timestamp
        );
    }
    
    // ========== VIEW FUNCTIONS ==========
    
    /**
     * @notice Get user's total balance
     * @param _user User address
     * @return Total balance in wei
     */
    function getBalance(address _user) external view returns (uint256) {
        return balances[_user];
    }
    
    /**
     * @notice Get user's locked balance
     * @param _user User address
     * @return Locked balance in wei
     */
    function getLockedBalance(address _user) external view returns (uint256) {
        return lockedBalances[_user];
    }
    
    /**
     * @notice Get user's available (unlocked) balance
     * @param _user User address
     * @return Available balance in wei
     */
    function getAvailableBalance(address _user) external view returns (uint256) {
        return balances[_user] - lockedBalances[_user];
    }
    
    /**
     * @notice Get full balance info for a user
     * @param _user User address
     * @return total Total balance in wei
     * @return locked Locked balance in wei
     * @return available Available balance in wei
     */
    function getBalanceInfo(address _user) external view returns (
        uint256 total,
        uint256 locked,
        uint256 available
    ) {
        total = balances[_user];
        locked = lockedBalances[_user];
        available = total - locked;
    }
    
    /**
     * @notice Check if address is an operator
     * @param _operator Address to check
     * @return bool True if operator
     */
    function isOperator(address _operator) external view returns (bool) {
        return operators[_operator];
    }
    
    /**
     * @notice Get contract's total ETH balance
     * @return Contract balance in wei
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    // ========== FALLBACK ==========
    
    // Accept direct ETH transfers (treated as deposits)
    receive() external payable {
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value, balances[msg.sender], block.timestamp);
    }
}
