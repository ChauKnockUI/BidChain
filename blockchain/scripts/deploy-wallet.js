// scripts/deploy-wallet.js
// Using ethers v5 syntax (hardhat-toolbox 2.x)
const hre = require("hardhat");

async function main() {
    console.log("Deploying BidChainWallet contract...");

    const [deployer] = await hre.ethers.getSigners();
    console.log("Deploying with account:", deployer.address);

    const balance = await deployer.getBalance();
    console.log("Account balance:", hre.ethers.utils.formatEther(balance), "ETH");

    // Deploy BidChainWallet using hardhat ethers v5
    const BidChainWallet = await hre.ethers.getContractFactory("BidChainWallet");
    const wallet = await BidChainWallet.deploy();

    // Wait for deployment - ethers v5 style
    await wallet.deployed();
    const walletAddress = wallet.address;

    console.log("=====================================");
    console.log("WALLET_CONTRACT_ADDRESS=" + walletAddress);
    console.log("=====================================");

    // AUTOMATICALLY UPDATE BACKEND .ENV FILE
    const fs = require('fs');
    const path = require('path');

    const backendEnvPath = path.join(__dirname, '../../backend/.env');

    try {
        let envContent = fs.readFileSync(backendEnvPath, 'utf8');

        // Remove old WALLET_CONTRACT_ADDRESS if exists
        envContent = envContent.replace(/^WALLET_CONTRACT_ADDRESS=.*$/gm, '');
        envContent = envContent.replace(/\n+$/g, '\n'); // Clean trailing newlines

        // Add new address
        envContent += `WALLET_CONTRACT_ADDRESS=${walletAddress}\n`;

        fs.writeFileSync(backendEnvPath, envContent);
        console.log("✅ Updated backend .env with WALLET_CONTRACT_ADDRESS");
    } catch (err) {
        console.log("⚠️ Could not update .env:", err.message);
        console.log("   Manually add: WALLET_CONTRACT_ADDRESS=" + walletAddress);
    }

    // Copy ABI to backend
    const artifactPath = path.join(__dirname, '../artifacts/contracts/BidChainWallet.sol/BidChainWallet.json');
    const backendAbiPath = path.join(__dirname, '../../backend/abi/BidChainWallet.json');

    try {
        fs.copyFileSync(artifactPath, backendAbiPath);
        console.log("✅ ABI copied to backend/abi/BidChainWallet.json");
    } catch (err) {
        console.log("⚠️ Could not copy ABI:", err.message);
    }

    console.log("\n🎉 Deployment complete! Restart backend to use new contract.");

    return walletAddress;
}

main()
    .then((address) => {
        process.exit(0);
    })
    .catch((error) => {
        console.error("❌ Deployment failed:", error);
        process.exit(1);
    });
