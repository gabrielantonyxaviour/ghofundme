# TODO

1. Integrate the module to work and mint normally - 1 hour - DONE
2. Integrate CCIP - 2 hours- ALMOST DONE
3. Test CCIP - 2 hours
4. Create proper ERC4626 Vault - 1 hour - DONE
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
2.

# Contract Architecture

1. VaultFactory (Ethereum)
   - Deploy vault (Only called by GHOFundMe module in Polygon)
2. GHOFundMe Vault (Ethereum)
   - Subscribe (Called by anyone sends cross chain call using CCIP)
     1. Permit the GHO tokens to be transferred to the vault using permit signature (Ethereum)
     2. Increment Total Value locked by the fan (Ethereum)
     3. Add the value into the total value locked in a month window (Ethereum)
     4. Send the success message back to Polygon. (Ethereum)
     5. If success, mint the fan tokens to the user. (Polygon)
   - Claim Rewards By Creator
     1. Check if claimed till previous window
     2. Set Latest Claimed window to the window till claimed
     3. Transfer rewards to the creator
3. GHOFundMe Module (Polygon)
   - Create Fan Token (Called by any Lens Account Holder to create fan tokens and deploy a vault on Ethereum)
   - Terminate Subscription By User (Called by Anyone)

# Contract Actions in the Frontend

    - Create Lens Profile - Creator (DEMO)
    - Enable GHOFundMe Module - Fans (DEMO)
    - Create GHOFundMe Profile - Creator (DEMO) | Our Contract
    - Subscribe using Follow Module - Fans (DEMO) | Our Contract
    - Subscribe without using Follow Module - Fans (DEMO) | Our Contract
    - Claim Rewards - Creator | Our Contract
    - Terminate Subscription  - Fans | Our Contract

# Subscribe functionality

# Termination functionality

1. Get the price it was locked for (Polygon)
2. Check if the fan holds the right amount of Fan Trade and Fan Mint tokens
3. Make

# Claim rewards functionality

1. Check if claimed till previous window
2. Set Latest Claimed window to the window till claimed
3. Transfer rewards to the creator
