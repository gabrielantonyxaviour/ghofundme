const { networks } = require("../../networks")
task("deploy-implementation", "Deploys the GHOFundMeVaultImplementation contract")
  .addOptionalParam("verify", "Set to true to verify contract", false, types.boolean)
  .setAction(async (taskArgs) => {
    console.log(`Deploying GHOFundMeVaultImplementation contract to ${network.name}`)

    console.log("\n__Compiling Contracts__")
    await run("compile")

    const implementationFactory = await ethers.getContractFactory("GHOFundMeVaultImplementation")
    const implementation = await implementationFactory.deploy(networks[network.name].router)

    console.log(`\nWaiting blocks for transaction ${implementation.deployTransaction.hash} to be confirmed...`)

    await implementation.deployTransaction.wait(networks[network.name])

    console.log("\nDeployed GHOFundMeVaultImplementation contract to:", implementation.address)

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
          address: implementation.address,
          constructorArguments: [
            sourceCode,
            linkTokenAddress,
            ccipRouterAddress,
            functionsRouter,
            donId,
            chainSelector,
            subId,
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

    console.log(`\n GHOFundMeVaultImplementation contract deployed to ${implementation.address} on ${network.name}`)
  })
