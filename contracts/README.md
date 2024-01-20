# TODO

1. Integrate the module to work and mint normally - 1 hour
2. Integrate CCIP and test - 2 hours
3. Create proper ERC4626 Vault - 1 hour
4. Try to make Yield thing work - 1 hour
5. Make everything work - 4 hours
6. Extra buffer time - 4 hours
7. Integrate contract calls - 2 hours
8. Integrate scripts to fetch - 1 hour
9. Write tests if possible - 3 hours
10. Prepare the pitch - 4 hours

# Contract Actions

1. Create Creator Profile by Creator (Action Performed on Polygon to the GHOFundMe Module by enabling the module)
   - Creates Fan Mint and Fan Trade Tokens
   - Send cross chain Transaction to the vault Factory to deploy the vault
2. ## If already following, the user can just directly call the Module to perform the minting of tokens. Follows using the Follow Modules

# Contract Architecture

1. VaultFactory (Ethereum)
   - Deploy vault (Only called by GHOFundMe module in Polygon)
2. ERC4626 Vault
   - Lock Funds By Module (Only called by GHOFundMe module in Polygon)
   - Lock Funds By User (Called by anyone. Recovery function to try again in case the transaction failed in ccipReceive)
   - Claim Rewards By Creator
3. GHOFundMe Module
   - Subscribe By User (Called by anyone)
   - Terminate Subscription By User (Called by Anyone)

# Contract Actions in the Frontend

    - Create Lens Profile - Creator (DEMO)
    - Enable GHOFundMe Module - Fans (DEMO)
    - Create GHOFundMe Profile - Creator (DEMO) | Our Contract
    - Subscribe using Follow Module - Fans (DEMO) | Our Contract
    - Subscribe without using Follow Module - Fans (DEMO) | Our Contract
    - Claim Rewards - Creator | Our Contract
    - Terminate Subscription  - Fans | Our Contract
