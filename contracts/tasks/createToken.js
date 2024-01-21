const { DEFAULT_VERIFICATION_BLOCK_CONFIRMATIONS } = require("../networks")
task("create-token", "Creating a new fan token using GHOFundMeModule").setAction(async (taskArgs) => {
  const createTokenInputParams = [
    "MINT_TOKEN_NAME",
    "TRADE_TOKEN_NAME",
    "MINT_TOKEN_SYMBOL",
    "TRADE_TOKEN_SYMBOL",
    "MINT_TOKEN_URI",
    "TRADE_TOKEN_URI",
    1105,
    1000000000000,
    2,
  ]

  const moduleFactory = await ethers.getContractFactory("GHOFundMeModule")
  const moduleContract = moduleFactory.attach(moduleAddress)

  const tx = await moduleContract.createToken(createTokenInputParams)

  const receipt = await tx.wait(DEFAULT_VERIFICATION_BLOCK_CONFIRMATIONS)

  console.log("Transaction confirmed")
  console.log("Transaction hash:", tx.hash)
})
