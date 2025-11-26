// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @title BidChain Auction Contract
 * @notice Off-chain bidding with on-chain settlement
 * @dev Conversion Layer: VND display, ETH storage
 */
contract Auction {

    using ECDSA for bytes32;

    // Auction metadata structure
    struct AuctionMetadata {
        uint256 id;
        address payable seller;
        string metadataUrl;
        uint256 startPriceWei;      // Starting price in Wei
        uint256 stepPriceWei;       // Step price in Wei
        uint256 endTime;
        bool ended;
        bool settled;
        address winner;
        uint256 finalPriceWei;
        string contractAddress;     // For future cross-contract calls
    }

    // EIP-712 Domain Separator
    bytes32 private constant EIP712_DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );

    bytes32 private constant BID_TYPEHASH = keccak256(
        "Bid(string auctionId,uint256 amount,uint256 nonce,uint256 timestamp)"
    );

    bytes32 private immutable DOMAIN_SEPARATOR;

    mapping(uint256 => AuctionMetadata) public auctions;
    uint256 public auctionCount;

    // Events
    event AuctionCreated(
        uint256 indexed auctionId,
        address indexed seller,
        uint256 startPriceWei,
        uint256 stepPriceWei,
        uint256 endTime,
        string metadataUrl
    );

    event AuctionSettled(
        uint256 indexed auctionId,
        address indexed winner,
        address indexed seller,
        uint256 finalPriceWei
    );

    event AuctionCancelled(
        uint256 indexed auctionId
    );

    // Modifiers
    modifier onlySeller(uint256 _auctionId) {
        require(auctions[_auctionId].seller == msg.sender, "Not seller");
        _;
    }

    modifier auctionExists(uint256 _auctionId) {
        require(_auctionId > 0 && _auctionId <= auctionCount, "Auction not found");
        _;
    }

    modifier notEnded(uint256 _auctionId) {
        require(!auctions[_auctionId].ended, "Auction ended");
        require(block.timestamp < auctions[_auctionId].endTime, "Auction expired");
        _;
    }

    constructor() {
        DOMAIN_SEPARATOR = keccak256(abi.encode(
            EIP712_DOMAIN_TYPEHASH,
            keccak256(bytes("BidChain")),
            keccak256(bytes("1.0")),
            block.chainid,
            address(this)
        ));
    }

    /**
     * @notice Create new auction metadata on-chain
     * @param _startPriceWei Starting price in Wei
     * @param _stepPriceWei Step price in Wei
     * @param _durationInSeconds Auction duration
     * @param _metadataUrl IPFS metadata URL
     * @return auctionId The ID of created auction
     */
    function createAuction(
        uint256 _startPriceWei,
        uint256 _stepPriceWei,
        uint256 _durationInSeconds,
        string memory _metadataUrl
    )
        external
        returns (uint256)
    {
        require(_startPriceWei > 0, "Invalid start price");
        require(_stepPriceWei > 0, "Invalid step price");
        require(_durationInSeconds >= 300, "Duration too short"); // Min 5 minutes

        auctionCount++;

        auctions[auctionCount] = AuctionMetadata({
            id: auctionCount,
            seller: payable(msg.sender),
            metadataUrl: _metadataUrl,
            startPriceWei: _startPriceWei,
            stepPriceWei: _stepPriceWei,
            endTime: block.timestamp + _durationInSeconds,
            ended: false,
            settled: false,
            winner: address(0),
            finalPriceWei: 0,
            contractAddress: ""
        });

        emit AuctionCreated(
            auctionCount,
            msg.sender,
            _startPriceWei,
            _stepPriceWei,
            block.timestamp + _durationInSeconds,
            _metadataUrl
        );

        return auctionCount;
    }

    /**
     * @notice Settle auction after bidding ends (called by backend)
     * @param _auctionId Auction ID
     * @param _winner Winner address
     * @param _finalPriceWei Final price in Wei
     */
    function settleAuction(
        uint256 _auctionId,
        address _winner,
        uint256 _finalPriceWei
    )
        external
        auctionExists(_auctionId)
        onlySeller(_auctionId)
    {
        AuctionMetadata storage auction = auctions[_auctionId];

        require(!auction.settled, "Already settled");
        require(auction.ended || block.timestamp >= auction.endTime, "Auction not ended");

        auction.ended = true;
        auction.settled = true;
        auction.winner = _winner;
        auction.finalPriceWei = _finalPriceWei;

        // Transfer ETH from winner to seller
        if (_winner != address(0) && _finalPriceWei > 0) {
            require(address(this).balance >= _finalPriceWei, "Insufficient contract balance");

            (bool success, ) = auction.seller.call{value: _finalPriceWei}("");
            require(success, "Settlement transfer failed");
        }

        emit AuctionSettled(_auctionId, _winner, auction.seller, _finalPriceWei);
    }

    /**
     * @notice Emergency cancel auction (only by seller before any bids)
     * @param _auctionId Auction ID to cancel
     */
    function cancelAuction(uint256 _auctionId)
        external
        auctionExists(_auctionId)
        onlySeller(_auctionId)
        notEnded(_auctionId)
    {
        AuctionMetadata storage auction = auctions[_auctionId];

        // Only allow cancel if no winner set (no bidding happened)
        require(auction.winner == address(0), "Cannot cancel after bidding started");

        auction.ended = true;

        emit AuctionCancelled(_auctionId);
    }

    /**
     * @notice Verify EIP-712 bid signature (optional utility)
     * @param _auctionId Auction ID as string
     * @param _amountWei Bid amount in Wei
     * @param _nonce User nonce
     * @param _timestamp Bid timestamp
     * @param _signature EIP-712 signature
     * @param _expectedSigner Expected signer address
     * @return True if signature is valid
     */
    function verifyBidSignature(
        string memory _auctionId,
        uint256 _amountWei,
        uint256 _nonce,
        uint256 _timestamp,
        bytes memory _signature,
        address _expectedSigner
    )
        external
        view
        returns (bool)
    {
        bytes32 structHash = keccak256(abi.encode(
            BID_TYPEHASH,
            keccak256(bytes(_auctionId)),
            _amountWei,
            _nonce,
            _timestamp
        ));

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            structHash
        ));

        address recoveredSigner = digest.recover(_signature);
        return recoveredSigner == _expectedSigner;
    }

    /**
     * @notice Get auction metadata
     * @param _auctionId Auction ID
     * @return AuctionMetadata struct
     */
    function getAuction(uint256 _auctionId)
        external
        view
        auctionExists(_auctionId)
        returns (AuctionMetadata memory)
    {
        return auctions[_auctionId];
    }

    /**
     * @notice Check if auction can receive bids
     * @param _auctionId Auction ID
     * @return True if auction is active
     */
    function isAuctionActive(uint256 _auctionId)
        external
        view
        auctionExists(_auctionId)
        returns (bool)
    {
        AuctionMetadata memory auction = auctions[_auctionId];
        return !auction.ended && block.timestamp < auction.endTime;
    }

    /**
     * @notice Get contract ETH balance
     * @return Contract balance in Wei
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @notice Emergency withdraw (only owner - add access control in production)
     * @param _amount Amount to withdraw
     */
    function emergencyWithdraw(uint256 _amount) external {
        // TODO: Add onlyOwner modifier
        require(_amount <= address(this).balance, "Insufficient balance");
        payable(msg.sender).transfer(_amount);
    }

    // Fallback function to receive ETH
    receive() external payable {}
}
