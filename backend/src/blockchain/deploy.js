

const ethers = require("ethers");
require("dotenv").config();

// ethers v5 syntax
const provider = new ethers.providers.JsonRpcProvider(
    process.env.RPC_URL || "http://127.0.0.1:7545"
);

const wallet = new ethers.Wallet(
    process.env.DEPLOYER_PRIVATE_KEY,
    provider
);

// Đọc artifact từ Hardhat
// src/blockchain/deploy.js - ĐÃ SỬA ĐÚNG
const AUCTION_ARTIFACT = require("../../../blockchain/artifacts/contracts/Auction.sol/Auction.json");
const AUCTION_ABI = AUCTION_ARTIFACT.abi;
const AUCTION_BYTECODE = AUCTION_ARTIFACT.bytecode;


async function deployAuctionContract(auctionData) {
    try {
        console.log("Bắt đầu deploy contract Auction (ethers v5)...");

        // Tạo factory
        const AuctionFactory = new ethers.ContractFactory(AUCTION_ABI, AUCTION_BYTECODE, wallet);

        // Deploy contract
        const contract = await AuctionFactory.deploy();
        console.log("Đang deploy... tx:", contract.deployTransaction.hash);

        // Chờ deploy xong
        await contract.deployed(); // ← ethers v5

        const contractAddress = contract.address;
        console.log("Contract deployed tại:", contractAddress);

        // Tính duration
        const durationSeconds = Math.floor(
            (new Date(auctionData.end_time) - Date.now()) / 1000
        );

        if (durationSeconds < 300) {
            throw new Error("Thời gian đấu giá phải ≥ 5 phút");
        }

        console.log(`Tạo auction trên chain (duration: ${durationSeconds}s)...`);
        const tx = await contract.createAuction(
            auctionData.start_price.toString(),
            auctionData.step_price.toString(),
            durationSeconds,
            auctionData.title || "No metadata"
        );

        console.log("Chờ transaction confirm...");
        const receipt = await tx.wait();

        // Extract blockchain_id from AuctionCreated event
        const auctionCreatedEvent = receipt.events?.find(e => e.event === 'AuctionCreated');
        const blockchain_id = auctionCreatedEvent?.args?.auctionId?.toNumber() || 1;

        console.log("✅ Tạo auction thành công!");
        console.log(`   Contract Address: ${contractAddress}`);
        console.log(`   Blockchain ID: ${blockchain_id}`);

        // Return both contract address and blockchain_id
        return {
            contract_address: contractAddress,
            blockchain_id: blockchain_id
        };

    } catch (error) {
        console.error("Deploy thất bại:", error);
        throw new Error(`Deploy failed: ${error.message || error}`);
    }
}

module.exports = { deployAuctionContract };
