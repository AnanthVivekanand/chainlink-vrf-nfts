import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require('@openzeppelin/hardhat-upgrades');


const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    hardhat: {
    },
    sepolia: {
      url: "https://ethereum-sepolia.publicnode.com",
      accounts: ["private_key"]
    }
  }
};

export default config;
