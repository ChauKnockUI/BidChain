const fs = require("fs");
const path = require("path");
const hre = require("hardhat");

async function main() {
  const Auction = await hre.ethers.getContractFactory("Auction");
  const auction = await Auction.deploy();

  await auction.deployed();

  console.log("Auction deployed to:", auction.address);

  // ===== AUTO UPDATE BACKEND .env =====

  const backendEnvPath = path.join(__dirname, "../../backend/.env");

  // Đọc file .env
  let env = fs.readFileSync(backendEnvPath, "utf8").split("\n");

  // Tìm dòng CONTRACT_ADDRESS
  const index = env.findIndex((line) =>
    line.startsWith("CONTRACT_ADDRESS=")
  );

  if (index !== -1) {
    env[index] = `CONTRACT_ADDRESS=${auction.address}`;
  } else {
    env.push(`CONTRACT_ADDRESS=${auction.address}`);
  }

  // Ghi lại file
  fs.writeFileSync(backendEnvPath, env.join("\n"), "utf8");

  console.log("Updated backend .env with CONTRACT_ADDRESS =", auction.address);
  console.log("Done!");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
