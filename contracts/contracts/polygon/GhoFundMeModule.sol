// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@aave/lens-protocol/contracts/interfaces/IFollowModule.sol";
import "@aave/lens-protocol/contracts/core/modules/ModuleBase.sol";
import "@aave/lens-protocol/contracts/core/modules/follow/FollowValidatorFollowModuleBase.sol";
import "./base/GhoFundMeModuleBase.sol";

contract GHOFundMeFollowModule is  GhoFundMeModuleBase, FollowValidatorFollowModuleBase {

    address public owner;

    string private _moduleMetadataURI;

    constructor(address hub, address moduleGlobals) GhoFundMeModuleBase(moduleGlobals)  ModuleBase(hub) {}

  	function supportsInterface(bytes4 interfaceID) public pure  returns (bool) {
    	return interfaceID == type(IFollowModule).interfaceId;
 	}

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address owner_) external onlyOwner {
        owner = owner_;
    }
  
    function initializeFollowModule(
		uint256 profileId,
        bytes calldata data
    )
        external
        override
        onlyHub
        returns (bytes memory)
    {
  
    }

    function processFollow(
        address follower,
        uint256 profileId,
        bytes calldata data
    ) external override onlyHub {
       
    }

    function followModuleTransferHook(
        uint256 profileId,
        address from,
        address to,
        uint256 followNFTTokenId
    ) external override {}

    function setModuleMetadatURI(string memory uri) external onlyOwner {
        _moduleMetadataURI=uri;  
    }
  
    function get_moduleMetadataURI() external view returns (string memory) {
        return _moduleMetadataURI;
    }
}