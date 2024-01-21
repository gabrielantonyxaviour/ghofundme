const { DEFAULT_VERIFICATION_BLOCK_CONFIRMATIONS } = require("../networks")
task("terminate-subscription", "Terminating a subscription to a creator using GHOFundMeModule").setAction(
  async (taskArgs) => {
    const lensProfileId = 1105
    const tokenAmount = 2
    const moduleAddress = networks.polygonMumbai.module

    const moduleFactory = await ethers.getContractFactory("GHOFundMeModule")
    const moduleContract = moduleFactory.attach(moduleAddress)

    const tx = await moduleContract.terminateSubscription(lensProfileId, tokenAmount)

    const receipt = await tx.wait(DEFAULT_VERIFICATION_BLOCK_CONFIRMATIONS)

    console.log("Transaction confirmed")
    console.log("Transaction hash:", tx.hash)
  }
)
