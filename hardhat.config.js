require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
//require("@nomiclabs/hardhat-waffle");
require("dotenv").config();
require("solidity-coverage");
require("@openzeppelin/hardhat-upgrades");

const PRIVATE_KEY = process.env.PRIVATE_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  networks: {
    // hardhat: {
    //   forking: {
    //     url: `https://polygon-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_KEY}`,
    //     //blockNumber: 33176170,
    //   },
    // },
    localhost: {
      url: "http://localhost:8545", // uses account 0 of the hardhat node to deploy
    },
    matic: {
      url: "https://polygon-rpc.com",
      accounts: [`0x${PRIVATE_KEY}`],
      gasPrice: 90000000000, //30 gwei
    },
    mumbai: {
      url: `https://matic-mumbai.chainstacklabs.com`,
      accounts: [`0x${PRIVATE_KEY}`],
      gasPrice: 30000000000, //30 gwei
    },
    harmony_test: {
      url: `https://api.s0.b.hmny.io`,
      accounts: [`0x${PRIVATE_KEY}`],
    },

    goerli: {
      url: `https://eth-goerli.g.alchemy.com/v2/G_PPRfMNF_Gi6odHFpmx34hoT6g3I1mE`,
      accounts: [`0x${PRIVATE_KEY}`],
      // gasPrice: 320000000000, //30 gwei
    },
  },

  solidity: {
    compilers: [
      {
        version: "0.8.17",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.8.4",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.8.10",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },

  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: process.env.ETHERSCAN_API_KEY,
    //apiKey: process.env.POLYGON_API_KEY,
  },
};
