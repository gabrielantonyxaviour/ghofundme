const { networks } = require("../../networks")
task("deploy-mint-token", "Deploys the GHOFanTokenMint contract")
  .addOptionalParam("verify", "Set to true to verify contract", false, types.boolean)
  .setAction(async (taskArgs) => {
    console.log(`Deploying GHOFanTokenMint contract to ${network.name}`)

    console.log("\n __Compiling Contracts__")
    await run("compile")
    if (network.name != "polygonMumbai") {
      throw Error("Module should be deployed to polygonMumbai")
    }
    const mintTokenFactory = await ethers.getContractFactory("GHOFanTokenMint")
    const mintToken = await mintTokenFactory.deploy(networks[network.name].module)

    console.log(`\n Waiting blocks for transaction ${mintToken.deployTransaction.hash} to be confirmed...`)

    await mintToken.deployTransaction.wait(networks[network.name])

    console.log("\n Deployed GHOFanTokenMint contract to:", mintToken.address)

    networks[network.name].mintToken = mintToken.address

    if (network.name === "localFunctionsTestnet") {
      return
    }

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
          address: mintToken.address,
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

    console.log(`\n GHOFanTokenMint contract deployed to ${mintToken.address} on ${network.name}`)
  })
