// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@aave/lens-protocol/contracts/interfaces/IFollowModule.sol";
import "@aave/lens-protocol/contracts/core/modules/ModuleBase.sol";
import "./base/GhoFundMeModuleBase.sol";

contract GHOFundMeFollowModule is  ModuleBase, GhoFundMeModuleBase, IFollowModule {

    constructor(address hub) ModuleBase(hub) {}

  	// function supportsInterface(bytes4 interfaceID) public pure override returns (bool) {
    // 	return interfaceID == type(IFollowModule).interfaceId || super.supportsInterface(interfaceID);
 	// }
  
    function initializeFollowModule(
		uint256 profileId,
        address transactionExecutor,
        bytes calldata data
    )
        external
        override
        onlyHub
        returns (bytes memory)
    {
  
    }

    function processFollow(
		uint256 followerProfileId,
        uint256 followerTokenId,
        address transactionExecutor,
        uint256 targetProfileId,
        bytes calldata data
    ) external view override {
 
    }
  
    function getModuleMetadataURI() external view returns (string memory) {
        return 'yourModuleMetadataUriHere';
    }
}