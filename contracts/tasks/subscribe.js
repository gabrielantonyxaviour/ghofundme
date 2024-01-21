const { DEFAULT_VERIFICATION_BLOCK_CONFIRMATIONS } = require("../networks")
task("subscribe", "Subscribing a creator using GHOFundMeVault").setAction(async (taskArgs) => {
  const lensProfileId = 1105
  const amountInGHO = 3000000000000
  const deadline = "2384723984723985798237983278237"
  const v = ""
  const r = ""
  const s = ""
  const moduleFactory = await ethers.getContractFactory("GHOFundMeModule")
  const moduleContract = moduleFactory.attach(moduleAddress)

  const tx = await moduleContract.subscribe(lensProfileId, amountInGHO, deadline, v, r, s)

  const receipt = await tx.wait(DEFAULT_VERIFICATION_BLOCK_CONFIRMATIONS)

  console.log("Transaction confirmed")
  console.log("Transaction hash:", tx.hash)
})
