const { networks } = require("../../networks")
task("deploy-trade-token", "Deploys the GHOFanTokenTrade contract")
  .addOptionalParam("verify", "Set to true to verify contract", false, types.boolean)
  .setAction(async (taskArgs) => {
    console.log(`Deploying GHOFanTokenTrade contract to ${network.name}`)

    console.log("\n __Compiling Contracts__")
    await run("compile")
    if (network.name != "polygonMumbai") {
      throw Error("Module should be deployed to polygonMumbai")
    }
    const tradeTokenFactory = await ethers.getContractFactory("GHOFanTokenTrade")
    const tradeToken = await tradeTokenFactory.deploy(networks[network.name].module)

    console.log(`\n Waiting blocks for transaction ${tradeToken.deployTransaction.hash} to be confirmed...`)

    await tradeToken.deployTransaction.wait(networks[network.name])

    console.log("\n Deployed GHOFanTokenTrade contract to:", tradeToken.address)

    networks[network.name].tradeToken = tradeToken.address

    if (network.name === "localFunctionsTestnet") {
      return
    }
    await new Promise((r) => setTimeout(r, 10000))

    const verifyContract = taskArgs.verify
    if (
      network.name !== "localFunctionsTestnet" &&
      verifyContract &&
      !!networks[network.name].verifyApiKey &&
      networks[network.name].verifyApiKey !== "UNSET"
    ) {
      try {
        console.log("\nVerifying contract...")
        await run("verify:verify", {
          address: tradeToken.address,
          constructorArguments: [networks[network.name].module],
        })
        console.log("Contract verified")
      } catch (error) {
        if (!error.message.includes("Already Verified")) {
          console.log(
            "Error verifying contract.  Ensure you are waiting for enough confirmation blocks, delete the build folder and try again."
          )
          console.log(error)
        } else {
          console.log("Contract already verified")
        }
      }
    } else if (verifyContract && network.name !== "localFunctionsTestnet") {
      console.log(
        "\nPOLYGONSCAN_API_KEY, ETHERSCAN_API_KEY or FUJI_SNOWTRACE_API_KEY is missing. Skipping contract verification..."
      )
    }

    console.log(`\n GHOFanTokenTrade contract deployed to ${tradeToken.address} on ${network.name}`)
  })
