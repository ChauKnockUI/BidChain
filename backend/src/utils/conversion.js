const { EXCHANGE_RATE } = require('../config/constants');
const { ethers } = require('ethers');

// Helper an toàn: chuyển ETH string/number → wei string
const toWei = (eth) => {
  if (!eth || parseFloat(eth) <= 0) return "0";
  return ethers.utils.parseEther(eth.toString()).toString();
};

// Helper: wei string → số VND (làm tròn)
const weiToVnd = (weiAmount) => {
  if (!weiAmount || weiAmount === "0") return 0;
  const ethAmount = ethers.utils.formatEther(weiAmount);
  return Math.round(parseFloat(ethAmount) * EXCHANGE_RATE.ETH_TO_VND);
};

// VND → wei string (dùng để bid, lock tiền)
const vndToWei = (vndAmount) => {
  if (!vndAmount || vndAmount <= 0) return "0";
  const ethAmount = vndAmount / EXCHANGE_RATE.ETH_TO_VND;
  return toWei(ethAmount.toFixed(18)); // parseEther sẽ xử lý chính xác
};

// VND → ETH string (dùng để hiển thị)
const vndToEth = (vndAmount) => {
  if (!vndAmount || vndAmount <= 0) return "0";
  return (vndAmount / EXCHANGE_RATE.ETH_TO_VND).toFixed(18);
};

// ETH → VND
const ethToVnd = (ethAmount) => {
  return Math.round(parseFloat(ethAmount) * EXCHANGE_RATE.ETH_TO_VND);
};

// Format VND đẹp
const formatVnd = (amount) => {
  if (!amount) return "0 ₫";
  return new Intl.NumberFormat("vi-VN", {
    style: "currency",
    currency: "VND",
    minimumFractionDigits: 0,
  }).format(amount);
};

// Format ETH đẹp
const formatEth = (amount) => {
  if (!amount) return "0.000000 ETH";
  const num = parseFloat(amount);
  return num < 0.000001 ? "<0.000001 ETH" : `${num.toFixed(6)} ETH`;
};

module.exports = {
  vndToWei,
  weiToVnd,
  vndToEth,
  ethToVnd,
  formatVnd,
  formatEth,
  toWei
};