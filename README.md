
![Ghfundme_1](https://github.com/gabrielantonyxaviour/ghofundme/assets/79229998/12d61674-fdf4-4d86-a11c-6b91d87d3ab4)

## Problem Statement
	There is no standard implementation to support content creators in web3. Social media applications like Instagram and Twitter have come up with ways to support the creator or subscribing to view exclusive content provided by the creator. Even though certain applications in web3 provide solutions to reward content creators in their own application. Is there a way to create a standard for subscription based rewards for creators and exclusive content for fans in web3 social media infrastructure like Lens?

## Solution/Project Description
	GHOFundMe is a custom Lens Module which acts as a feature for Lens creators to create a subscription based revenue. The Lens module is initialized for each content creator after a few eligibility checks like followers count, post interactions etc. On initializing the module for the content creator’s Lens account, a new vault is deployed where the fans can supply GHO tokens and get ERC1155 Fan Mint Tokens and ERC1155 Fan Trade Tokens in return. Mint Tokens are soulbound and non-tradeable(burnable when user terminates subscription). By owning these fan tokens, users can view exclusive content created by creators. The supplied GHO tokens are staked for a certain duration during which the user owns the Fan tokens. The vault basically acts as an escrow between the content creators and the fans. The fans can burn their fan tokens if they did not like the content/value provided by the creator to get back the GHO supplied after deducting the value of GHO for the amount of time the tokens were staked in the vault.

## Technical Description
  A custom Lens Module called GHOFundMe acts as the heart of this project. A vault is deployed on Ethereum which holds the GHO Tokens. ERC1155 Fan Mint Tokens and ERC1155 Trade Tokens are deployed and initialized when the GHOFundMe Module is deployed. The Lens Module on Polygon interacts with the VaultFactory and deploys the vault on Ethereum if not already deployed using Chainlink CCIP. Fans with a Lens account can fund GHO to the vault on Ethereum by passing the approvalSignature to the subscribe function in the vault which would transfer the GHO tokens from the fan to the vault and send a cross chain transaction to the Module which mints the Fan Mint Tokens and Fan Trade Tokens to the address which staked the GHO Tokens. The GHO Tokens are not immediately transferred or claimable by the Lens Creator but are staked  for a long period in the vault. Creator gets revenue for each second the user stakes the GHO tokens but this revenue can be claimed by the Lens Creator only at every 1 month window.

Let us consider the scenario where 1 Fan Token is priced at 1 GHO. When the fan with the Lens account subscribes by paying 100 GHO, he will receive 100 Fan Mint Tokens and 100 Fan Trade Tokens. Since the fan mint tokens are soul bound, they cannot be transferred. The Fan Trade tokens can be traded in a marketplace. To terminate a subscription, the user must hold 100 Fan Mint Tokens and 100 Fan Trade Tokens to burn them both and retrieve the staked GHO after deducting the value of the tokens for the period of time the funds were staked in the vault. Creator gets 20% of every trade of the Fan Trade Tokens, 5% to the protocol and 75% to the maker of the sell order. For Fan Token Mint, 90% goes to the creator, 10% protocol fee. 

## Flow Diagram

#### Create GHOFundMe Account for Creator



#### Deposit Funds and Mint Fan Tokens for Fans.



#### Terminate subscription with a creator for Fans.




#### Claim Revenue from subscription for Creator.


## Frontend
##### Business side
Create GHOFundMe profile
Login with your metamask
If you own Lens profile, proceed
Else break
GHOFundMe metadata 
Create Fan token
Image
Name
Set GHO deposit to Fan Token Mint proportion ( WORK TO BE DONE )
Duration of the deposit vs No. of tokens minted.
Amount of deposit vs No. of tokens minted.
Dashboard
View total revenue.
View Fan statistics and dropouts.

#### Fan side
Manage all active subscriptions.
Manage Fan token portfolio

#### Documentation



## SDK/Widget
A custom widget that users can integrate into their Lens applications. For the hackathon, we aim to integrate this widget into hey.xyz. This widget has a subscribe button which opens up a Modal, in which the GHOFundMe module requests the user to deposit GHO to receive Fan tokens. 




