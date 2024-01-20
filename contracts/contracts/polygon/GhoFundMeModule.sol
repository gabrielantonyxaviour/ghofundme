// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Create2.sol";

import "@aave/lens-protocol/contracts/interfaces/IFollowModule.sol";
import "@aave/lens-protocol/contracts/core/modules/ModuleBase.sol";
import "@aave/lens-protocol/contracts/core/modules/follow/FollowValidatorFollowModuleBase.sol";
import "./base/GhoFundMeModuleBase.sol";

error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); // Used to make sure contract has enough balance.
error NothingToWithdraw(); // Used when trying to withdraw Ether but there's nothing to withdraw.
error FailedToWithdrawEth(address owner, address target, uint256 value); // Used when the withdrawal of Ether fails.
error DestinationChainNotAllowlisted(uint64 destinationChainSelector); // Used when the destination chain has not been allowlisted by the contract owner.
error SourceChainNotAllowlisted(uint64 sourceChainSelector); // Used when the source chain has not been allowlisted by the contract owner.
error SenderNotAllowlisted(address sender); // Used when the sender has not been allowlisted by the contract owner.


contract GHOFundMeFollowModule is  GhoFundMeModuleBase, FollowValidatorFollowModuleBase,CCIPReceiver {

    IERC20 private s_linkToken;
    bytes32 private s_lastReceivedMessageId; // Store the last received messageId.
    bytes private s_lastReceivedData; // Store the last received data.

    // Mapping to keep track of allowlisted destination chains.
    mapping(uint64 => bool) public allowlistedDestinationChains;

    // Mapping to keep track of allowlisted source chains.
    mapping(uint64 => bool) public allowlistedSourceChains;

    // Mapping to keep track of allowlisted senders.
    mapping(address => bool) public allowlistedSenders;

    // Chain Selector for Sepolia
    uint64 public SEPOLIA_CHAIN_SELECTOR=16015286601757825753;

    // Chain Selector for Polygon
    uint64 public POLYGON_CHAIN_SELECTOR=12532609583862916517;

    address public owner;
    string private _moduleMetadataURI;
    address public vaultFactory;

    constructor(address hub, address moduleGlobals) GhoFundMeModuleBase(moduleGlobals)  ModuleBase(hub) {
        allowlistedDestinationChains[SEPOLIA_CHAIN_SELECTOR] = true;
        allowlistedDestinationChains[SEPOLIA_CHAIN_SELECTOR] = true;
    }

    function setVaultFactory(address _vaultFactory) external onlyOwner {
        vaultFactory = _vaultFactory;
        allowlistedSenders[_vaultFactory] = true;
    }

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