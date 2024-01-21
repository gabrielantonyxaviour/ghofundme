const { networks, DEFAULT_VERIFICATION_BLOCK_CONFIRMATIONS } = require("../../networks")
task("setup-module", "Setting up the GHOFundMeModule contract").setAction(async (taskArgs) => {
  const vaultFactory = networks.sepolia.vaultFactory
  const fanMintToken = networks.polygonMumbai.fanMintToken
  const fanTradeToken = networks.polygonMumbai.fanTradeToken

  const moduleAddress = networks.polygonMumbai.module

  const moduleFactory = await ethers.getContractFactory("GHOFundMeModule")
  const moduleContract = moduleFactory.attach(moduleAddress)

  const tx = await moduleContract.setupModule(vaultFactory, fanMintToken, fanTradeToken)

  const receipt = await tx.wait(DEFAULT_VERIFICATION_BLOCK_CONFIRMATIONS)

  console.log("Transaction confirmed")
  console.log("Transaction hash:", tx.hash)
})
