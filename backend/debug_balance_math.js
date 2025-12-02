const { ethers } = require("ethers");

// Mock Data
const balanceStr = "5000000000000000000"; // 5 ETH
const lockedStr = "1000000000000000000"; // 1 ETH
const bidAmountStr = "1000000000000000000"; // 1 ETH (Bid Amount)

console.log("--- Initial State ---");
console.log(`Balance: ${balanceStr}`);
console.log(`Locked: ${lockedStr}`);
console.log(`Bid Amount: ${bidAmountStr}`);

// Settlement Logic (Winner)
const winnerLockedBigInt = BigInt(lockedStr);
const bidAmountBigInt = BigInt(bidAmountStr);
const winnerBalanceBigInt = BigInt(balanceStr);

console.log("\n--- Settlement Calculation ---");
const newWinnerLocked = (winnerLockedBigInt - bidAmountBigInt).toString();
const newWinnerBalance = (winnerBalanceBigInt - bidAmountBigInt).toString();

console.log(`New Locked (Raw): ${newWinnerLocked}`);
console.log(`New Balance (Raw): ${newWinnerBalance}`);

const finalLocked = newWinnerLocked >= 0 ? newWinnerLocked : "0";
const finalBalance = newWinnerBalance >= 0 ? newWinnerBalance : "0";

console.log(`Final Locked: ${finalLocked}`);
console.log(`Final Balance: ${finalBalance}`);

// Verification
if (finalBalance === "4000000000000000000") {
    console.log("✅ Winner Balance Logic is CORRECT");
} else {
    console.error("❌ Winner Balance Logic is WRONG");
}

if (finalLocked === "0") {
    console.log("✅ Winner Locked Logic is CORRECT");
} else {
    console.error("❌ Winner Locked Logic is WRONG");
}

// Confirm Logic (Seller)
const sellerBalanceStr = "0";
const sellerBalanceBigInt = BigInt(sellerBalanceStr);
const newSellerBalance = (sellerBalanceBigInt + bidAmountBigInt).toString();

console.log("\n--- Seller Update Calculation ---");
console.log(`Seller Old Balance: ${sellerBalanceStr}`);
console.log(`New Seller Balance: ${newSellerBalance}`);

if (newSellerBalance === bidAmountStr) {
    console.log("✅ Seller Balance Logic is CORRECT");
} else {
    console.error("❌ Seller Balance Logic is WRONG");
}
