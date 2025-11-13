require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
  solidity: "0.8.20",
  networks: {
    ganache: {
      url: process.env.GANACHE_RPC || "http://127.0.0.1:7545",
      accounts: [process.env.DEPLOYER_PRIVATE_KEY]   
    }
  }
};
