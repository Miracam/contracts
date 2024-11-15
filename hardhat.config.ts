import 'dotenv/config'
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.27",
  networks: {
    baseSepolia: {
      url: process.env.BASE_SEPOLIA_RPC_URL || "https://sepolia.base.org", // https://docs.basescan.org/v/sepolia-basescan/
      accounts: [process.env.WALLET!],
      chainId: 84532,
    },
  }
};

export default config;
