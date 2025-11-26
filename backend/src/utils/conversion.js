// utils/conversion.js - PHIÊN BẢN ĐÃ SỬA HOÀN CHỈNH
const { EXCHANGE_RATE } = require('../config/constants');
const { ethers } = require('ethers');

// Helper: ETH string → wei string (an toàn)
const toWei = (eth) => {
  if (!eth || parseFloat(eth) <= 0) return "0";
  return ethers.utils.parseEther(eth.toString()).toString();
};

// Helper: wei string → ETH number (float, chỉ để hiển thị)
const weiToEth = (wei) => {
  if (!wei || wei === "0") return 0;
  return parseFloat(ethers.utils.formatEther(wei));
};

// wei string → số VND (làm tròn)
const weiToVnd = (weiAmount) => {
  if (!weiAmount || weiAmount === "0") return 0;
  const ethAmount = weiToEth(weiAmount);
  return Math.round(ethAmount * EXCHANGE_RATE.ETH_TO_VND);
};

// VND → wei string (dùng để bid, lock tiền)
const vndToWei = (vndAmount) => {
  if (!vndAmount || vndAmount <= 0) return "0";
  const ethAmount = vndAmount / EXCHANGE_RATE.ETH_TO_VND;
  return ethers.utils.parseEther(ethAmount.toFixed(18)).toString();
};

// VND → ETH string (hiển thị)
const vndToEth = (vndAmount) => {
  if (!vndAmount || vndAmount <= 0) return "0";
  return (vndAmount / EXCHANGE_RATE.ETH_TO_VND).toFixed(18);
};

// ETH string/number → VND
const ethToVnd = (ethAmount) => {
  const eth = parseFloat(ethAmount) || 0;
  return Math.round(eth * EXCHANGE_RATE.ETH_TO_VND);
};

// Format VND đẹp
const formatVnd = (amount) => {
  if (!amount || amount === 0) return "0 ₫";
  return new Intl.NumberFormat("vi-VN", {
    style: "currency",
    currency: "VND",
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(amount);
};

// Format ETH đẹp
const formatEth = (weiAmount) => {
  if (!weiAmount || weiAmount === "0") return "0 ETH";
  const eth = weiToEth(weiAmount);
  if (eth < 0.000001) return "<0.000001 ETH";
  return `${eth.toFixed(6).replace(/0+$/, '').replace(/\.$/, '')} ETH`;
};

module.exports = {
  toWei,
  weiToEth,
  weiToVnd,
  vndToWei,
  vndToEth,
  ethToVnd,
  formatVnd,
  formatEth
};