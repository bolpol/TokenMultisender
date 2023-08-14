import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-docgen";
import "dotenv/config";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 10000
      }
    }
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true
    },
    polygon: {
      url: process.env.POLYGON_URL || "",
      accounts:
          process.env.PRIVATE_KEY_PROD !== undefined ? [process.env.PRIVATE_KEY_PROD] : [],
    }
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  docgen: {
    path: './docs',
    clear: true,
    runOnCompile: false,
  }
};

export default config;
