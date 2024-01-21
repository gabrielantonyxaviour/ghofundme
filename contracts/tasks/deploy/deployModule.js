const { networks } = require("../../networks")
task("deploy-module", "Deploys the GHOFundMeModule contract")
  .addOptionalParam("verify", "Set to true to verify contract", false, types.boolean)
  .setAction(async (taskArgs) => {
    console.log(`Deploying GHOFundMeModule contract to ${network.name}`)

    console.log("\n__Compiling Contracts__")
    await run("compile")
    if (network.name != "polygonMumbai") {
      throw Error("Module should be deployed to polygonMumbai")
    }
    const moduleFactory = await ethers.getContractFactory("GHOFundMeModule")
    const module = await moduleFactory.deploy(
      networks.sepolia.implementation,
      networks[network.name].router,
      networks[network.name].link
    )

    console.log(`\nWaiting blocks for transaction ${module.deployTransaction.hash} to be confirmed...`)

    await module.deployTransaction.wait(networks[network.name])

    console.log("\nDeployed GHOFundMeModule contract to:", module.address)

    networks[network.name].module = module.address

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
          address: module.address,
          constructorArguments: [
            networks.sepolia.implementation,
            networks[network.name].router,
            networks[network.name].link,
          ],
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

    console.log(`\n GHOFundMeModule contract deployed to ${module.address} on ${network.name}`)
  })
