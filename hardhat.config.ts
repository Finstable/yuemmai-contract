import { HardhatUserConfig } from "hardhat/config";
import * as dotenv from "dotenv";

import "@typechain/hardhat";
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers";
import "hardhat-contract-sizer";
import { parseEther } from "ethers/lib/utils";

dotenv.config();

const getAccounts = () => {
  const arr = Object.entries(process.env);
  const privateKeys = arr
    .filter(([key, val]) => key.includes(`PRIVATE_KEY`))
    .map(([key, val]) => val || "");
  return privateKeys;
};

export default {
  solidity: {
    compilers: [
      {
        version: "0.8.11",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.6.7",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
      accounts: getAccounts().map((sk) => ({
        privateKey: sk,
        balance: parseEther("100000000").toString(),
      })),
    },
    kubchain_test: {
      url: `https://rpc-testnet.bitkubchain.io`,
      accounts: getAccounts(),
    },
    kubchain: {
      url: `https://rpc.bitkubchain.io`,
      accounts: getAccounts(),
    },
  },
} as HardhatUserConfig;
