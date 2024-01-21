const { networks } = require("../../networks")
task("deploy-vault-factory", "Deploys the GHOFundMeVaultFactory contract")
  .addOptionalParam("verify", "Set to true to verify contract", false, types.boolean)
  .setAction(async (taskArgs) => {
    console.log(`Deploying GHOFundMeVaultFactory contract to ${network.name}`)

    console.log("\n__Compiling Contracts__")
    await run("compile")
    if (network.name != "sepolia") {
      throw Error("Module should be deployed to sepolia")
    }
    const vaultFactory = await ethers.getContractFactory("GHOFundMeVaultFactory")
    const vault = await vaultFactory.deploy(
      networks.sepolia.implementation,
      networks[network.name].router,
      networks[network.name].link,
      networks.polygonMumbai.module
    )

    console.log(`\nWaiting blocks for transaction ${vault.deployTransaction.hash} to be confirmed...`)

    await vault.deployTransaction.wait(networks[network.name])

    console.log("\nDeployed GHOFundMeVaultFactory contract to:", vault.address)

    networks[network.name].vault = vault.address

    if (network.name === "localFunctionsTestnet") {
      return
    }

    networks[network.name].vaultFactory = vault.address

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
          address: vault.address,
          constructorArguments: [
            networks.sepolia.implementation,
            networks[network.name].router,
            networks[network.name].link,
            networks.polygonMumbai.module,
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

    console.log(`\n GHOFundMeVaultFactory contract deployed to ${vault.address} on ${network.name}`)
  })
