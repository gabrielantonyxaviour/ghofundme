require("@chainlink/env-enc").config()

const DEFAULT_VERIFICATION_BLOCK_CONFIRMATIONS = 3

const npmCommand = process.env.npm_lifecycle_event
const isTestEnvironment = npmCommand == "test" || npmCommand == "test:unit"

// Set EVM private keys (required)
const PRIVATE_KEY = process.env.PRIVATE_KEY

// TODO @dev - set this to run the accept.js task.
if (!isTestEnvironment && !PRIVATE_KEY) {
  throw Error("Set the PRIVATE_KEY environment variable with your EVM wallet private key")
}

const accounts = []
if (PRIVATE_KEY) {
  console.log("PRIVATE KEY 1 SET")
  accounts.push(PRIVATE_KEY)
}
const networks = {
  polygonMumbai: {
    url: process.env.POLYGON_MUMBAI_RPC_URL || "UNSET",
    gasPrice: 20_000_000_000,
    nonce: undefined,
    accounts,
    verifyApiKey: process.env.POLYGONSCAN_API_KEY || "UNSET",
    chainId: 80001,
    confirmations: 5,
    nativeCurrencySymbol: "MATIC",
    chainSelector: "12532609583862916517",
    router: "0x1035CabC275068e0F4b745A29CEDf38E13aF41b1",
    link: "0x326C977E6efc84E512bB9C30f76E30c160eD06FB",
    module: "0x231B9545e1E5BD31BA6546c6F69B3035183BE33A",
    mintToken: "0x7FF10b686aF179dfB489FeC0dB75D1B8dBb725f6",
    tradeToken: "0xF941a7A64503377a94a09B119838b452EE5f2bfd",
  },
  sepolia: {
    url: process.env.SEPOLIA_RPC_URL || "UNSET",
    gasPrice: 20_000_000_000,
    nonce: undefined,
    accounts,
    verifyApiKey: process.env.ETHERSCAN_API_KEY || "UNSET",
    chainId: 11155111,
    confirmations: 5,
    nativeCurrencySymbol: "ETH",
    chainSelector: "16015286601757825753",
    router: "0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59",
    link: "0x779877A7B0D9E8603169DdbD7836e478b4624789",
    ccipBnM: "0xFd57b4ddBf88a4e07fF4e34C487b99af2Fe82a05",
    ccipLnM: "0x466D489b6d36E7E3b824ef491C225F5830E81cC1",
    implementation: "0x03f67022442CB4dcdcf1e44f1C32B2bC208613AC",
    vaultFactory: "0x1BD651510c09384F7E0116b65514f8821d2e08a0",
  },
}

module.exports = {
  networks,
  DEFAULT_VERIFICATION_BLOCK_CONFIRMATIONS,
}
