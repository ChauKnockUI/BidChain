// test/check-wallet-config.js
// Check if BidChainWallet is correctly configured

require('dotenv').config();
const { ethers } = require('ethers');
const fs = require('fs');
const path = require('path');

console.log('\n========== WALLET CONTRACT DIAGNOSTIC ==========\n');

// 1. Check environment variable
const WALLET_CONTRACT_ADDRESS = process.env.WALLET_CONTRACT_ADDRESS;
console.log('1. WALLET_CONTRACT_ADDRESS:', WALLET_CONTRACT_ADDRESS || '❌ NOT SET');

if (!WALLET_CONTRACT_ADDRESS) {
    console.log('\n⚠️ WALLET_CONTRACT_ADDRESS is not set in .env');
    console.log('   Add this line to your .env file:');
    console.log('   WALLET_CONTRACT_ADDRESS=0x<your_deployed_address>');
    process.exit(1);
}

// 2. Check address format
console.log('2. Address length:', WALLET_CONTRACT_ADDRESS.length, '(should be 42)');
if (WALLET_CONTRACT_ADDRESS.length !== 42) {
    console.log('   ❌ Address is wrong length! Should be 42 characters including 0x');
    process.exit(1);
}

const isValid = ethers.utils.isAddress(WALLET_CONTRACT_ADDRESS);
console.log('3. Valid address format:', isValid ? '✅ Yes' : '❌ No');

if (!isValid) {
    console.log('   ❌ Address format is invalid');
    process.exit(1);
}

// 3. Check ABI file
const WALLET_ABI_PATH = process.env.WALLET_ABI_PATH || './abi/BidChainWallet.json';
console.log('4. ABI Path:', WALLET_ABI_PATH);

let walletAbi;
try {
    const raw = fs.readFileSync(path.resolve(WALLET_ABI_PATH), 'utf8');
    const parsed = JSON.parse(raw);
    walletAbi = parsed.abi || parsed;
    console.log('   ✅ ABI loaded successfully (' + walletAbi.length + ' entries)');
} catch (e) {
    console.log('   ❌ Cannot load ABI:', e.message);
    process.exit(1);
}

// 4. Test RPC connection
const RPC = process.env.GANACHE_RPC || 'http://127.0.0.1:7545';
console.log('5. RPC:', RPC);

const provider = new ethers.providers.JsonRpcProvider(RPC);

async function checkContract() {
    try {
        // Check if contract has code
        const code = await provider.getCode(WALLET_CONTRACT_ADDRESS);
        console.log('6. Contract deployed:', code !== '0x' ? '✅ Yes' : '❌ No (no code at address)');

        if (code === '0x') {
            console.log('\n⚠️ No contract found at this address!');
            console.log('   Run: npx hardhat run scripts/deploy-wallet.js --network ganache');
            process.exit(1);
        }

        // Try to call a simple function
        const walletContract = new ethers.Contract(WALLET_CONTRACT_ADDRESS, walletAbi, provider);

        // Get a random test address balance
        const testAddress = '0x0000000000000000000000000000000000000001';
        const balance = await walletContract.getBalance(testAddress);
        console.log('7. Contract callable:', '✅ Yes');
        console.log('   Test getBalance(0x0..01):', balance.toString(), 'wei');

        console.log('\n========== ✅ ALL CHECKS PASSED ==========');
        console.log('\nWallet contract is correctly configured!');
        console.log('Make sure to restart backend after updating .env\n');

    } catch (err) {
        console.log('❌ Error:', err.message);
    }
}

checkContract();
