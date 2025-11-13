// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Auction {

    struct AuctionItem {
        uint256 id;
        address payable seller;
        string metadataUrl;
        uint256 startingPrice;
        uint256 highestBid;
        address payable highestBidder;
        uint256 endTime;
        bool ended;
    }

    mapping(uint256 => AuctionItem) public auctions;
    uint256 public auctionCount;

    event AuctionCreated(
        uint256 indexed auctionId,
        address indexed seller,
        uint256 startingPrice,
        uint256 endTime
    );

    event NewBid(
        uint256 indexed auctionId,
        address indexed bidder,
        uint256 amount
    );

    event AuctionEnded(
        uint256 indexed auctionId,
        address indexed winner,
        uint256 finalAmount
    );

    event BidRefunded(
        uint256 indexed auctionId,
        address indexed oldBidder,
        uint256 amount
    );

    modifier onlyBeforeEnd(uint256 _auctionId) {
        require(!auctions[_auctionId].ended, "Already ended");
        require(block.timestamp < auctions[_auctionId].endTime, "Auction ended");
        _;
    }

    function createAuction(
        uint256 _startingPrice,
        uint256 _durationInSeconds,
        string memory _metadataUrl
    )
        external
        returns (uint256)
    {
        auctionCount++;

        auctions[auctionCount] = AuctionItem({
            id: auctionCount,
            seller: payable(msg.sender),
            metadataUrl: _metadataUrl,
            startingPrice: _startingPrice,
            highestBid: 0,
            highestBidder: payable(address(0)),
            endTime: block.timestamp + _durationInSeconds,
            ended: false
        });

        emit AuctionCreated(
            auctionCount,
            msg.sender,
            _startingPrice,
            block.timestamp + _durationInSeconds
        );

        return auctionCount;
    }


    function bid(uint256 _auctionId)
        external
        payable
        onlyBeforeEnd(_auctionId)
    {
        AuctionItem storage a = auctions[_auctionId];

        require(msg.value >= a.startingPrice, "Below starting price");
        require(msg.value > a.highestBid, "Bid not high enough");

        // Refund previous highest bidder
        if (a.highestBidder != address(0)) {
            uint256 prevAmount = a.highestBid;
            address payable prevBidder = a.highestBidder;

            (bool sent, ) = prevBidder.call{value: prevAmount}("");
            require(sent, "Refund failed");

            emit BidRefunded(_auctionId, prevBidder, prevAmount);
        }

        a.highestBid = msg.value;
        a.highestBidder = payable(msg.sender);

        emit NewBid(_auctionId, msg.sender, msg.value);
    }


    function endAuction(uint256 _auctionId)
        external
    {
        AuctionItem storage a = auctions[_auctionId];

        require(!a.ended, "Already ended");
        require(block.timestamp >= a.endTime, "Not reached end");

        a.ended = true;

        if (a.highestBidder != address(0)) {
            uint256 amount = a.highestBid;
            address payable seller = a.seller;

            (bool sent, ) = seller.call{value: amount}("");
            require(sent, "Pay seller failed");

            emit AuctionEnded(
                _auctionId,
                a.highestBidder,
                amount
            );
        } else {
            emit AuctionEnded(
                _auctionId,
                address(0),
                0
            );
        }
    }


    function getAuction(uint256 _auctionId)
        external
        view
        returns (AuctionItem memory)
    {
        return auctions[_auctionId];
    }

    function getAuctionCount()
        external
        view
        returns (uint256)
    {
        return auctionCount;
    }
}
