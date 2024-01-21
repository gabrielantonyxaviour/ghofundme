// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import "../interface/IGHOFundMeVaultFactory.sol";

error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); // Used to make sure contract has enough balance.
error NothingToWithdraw(); // Used when trying to withdraw Ether but there's nothing to withdraw.
error FailedToWithdrawEth(address owner, address target, uint256 value); // Used when the withdrawal of Ether fails.
error DestinationChainNotAllowlisted(uint64 destinationChainSelector); // Used when the destination chain has not been allowlisted by the contract owner.
error SourceChainNotAllowlisted(uint64 sourceChainSelector); // Used when the source chain has not been allowlisted by the contract owner.
error SenderNotAllowlisted(address sender); // Used when the sender has not been allowlisted by the contract owner.

contract GHOFundMeVaultImplementation is CCIPReceiver{
    bytes32 private s_lastReceivedMessageId; // Store the last received messageId.
    address public owner;
    bytes private s_lastReceivedData; // Store the last received data.
    address public rewardTokenAddress;
    IGHOFundMeVaultFactory public vaultFactory;

    // Mapping to keep track of allowlisted destination chains.
    mapping(uint64 => bool) public allowlistedDestinationChains;

    // Mapping to keep track of allowlisted source chains.
    mapping(uint64 => bool) public allowlistedSourceChains;

    // Mapping to keep track of allowlisted senders.
    mapping(address => bool) public allowlistedSenders;

    IERC20 private s_linkToken;

    // Chain Selector for Sepolia
    uint64 public SEPOLIA_CHAIN_SELECTOR=16015286601757825753;

    // Chain Selector for Mumbai
    uint64 public POLYGON_CHAIN_SELECTOR=12532609583862916517;

    uint256 public mintPriceInGHO;
    uint256 public minimumMintAmount;
    mapping(address => uint256) public userTotalLockedFunds;
    // mapping(address => )
    uint256 public totalLockedFunds;
    uint256 public totalClaimmableFunds;
    uint256 public lastClaimedTimestamp;



    /// @notice Constructor initializes the contract with the router address.
    /// @param _router The address of the router contract.
    /// @param _link The address of the link contract.
    constructor(address _router, address _link) CCIPReceiver(_router) {
        s_linkToken = IERC20(_link);
    }

    // Events

    // Event emitted when a message is sent to another chain.
    event MessageSent(
        bytes32 indexed messageId, // The unique ID of the CCIP message.
        uint64 indexed destinationChainSelector, // The chain selector of the destination chain.
        address receiver, // The address of the receiver on the destination chain.
        bytes data, // The data being sent.
        address feeToken, // the token address used to pay CCIP fees.
        uint256 fees // The fees paid for sending the CCIP message.
    );

    // Event emitted when a message is received from another chain.
    event MessageReceived(
        bytes32 indexed messageId, // The unique ID of the CCIP message.
        uint64 indexed sourceChainSelector, // The chain selector of the source chain.
        address sender, // The address of the sender from the source chain.
        bytes data // The data that was received.
    );

    // Event emitted when the contract owner changes.
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // Event emitted when the contract is initialized.
    event Initialized(address indexed creator, uint256 indexed lensProfileId, address indexed moduleAddress, uint64 chainSelector,address rewardTokenAddress);

    event SubscriptionInitiated(bytes32 indexed _messageId,address indexed subscriber,uint256 indexed lensProfileId,uint256 amountInGHO,uint256 totalFanTokensMinted);
    // Modifers

    /// @dev Modifier that checks if the sender is the owner of the contract.
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
    
    /// @dev Modifier that checks if the chain with the given destinationChainSelector is allowlisted.
    /// @param _destinationChainSelector The selector of the destination chain.
    modifier onlyAllowlistedDestinationChain(uint64 _destinationChainSelector) {
        if (!allowlistedDestinationChains[_destinationChainSelector])
            revert DestinationChainNotAllowlisted(_destinationChainSelector);
        _;
    }

    /// @dev Modifier that checks if the chain with the given sourceChainSelector is allowlisted and if the sender is allowlisted.
    /// @param _sourceChainSelector The selector of the destination chain.
    /// @param _sender The address of the sender.
    modifier onlyAllowlisted(uint64 _sourceChainSelector, address _sender) {
        if (!allowlistedSourceChains[_sourceChainSelector])
            revert SourceChainNotAllowlisted(_sourceChainSelector);
        if (!allowlistedSenders[_sender]) revert SenderNotAllowlisted(_sender);
        _;
    }

    /// @notice Allow the contract owner to transfer his ownership.
    /// @param newOwner The address of the new owner.
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        owner = newOwner;
        emit OwnershipTransferred(owner, newOwner);
    }

    // Contract Functions

    /// @notice Initializes the deployed proxy contract
    /// @param creator The address of the creator of the proxy contract
    /// @param lensProfileId The lens profile id of the creator
    /// @param moduleAddress The address of the GHOFundMe Module
    /// @param _rewardTokenAddress The address of the reward token
    /// @param _mintPriceInGHO The mint price in GHO
    /// @param _minimumMintAmount The minimum mint amount
    /// @param _chainSelector The chain selector of the source chain. ie. Polygon Mumbai
    function initialize(address creator, uint256 lensProfileId,address moduleAddress,address _rewardTokenAddress, uint256 _mintPriceInGHO,uint256 _minimumMintAmount,uint64 _chainSelector) external returns(bool) {
        require(owner == address(0), "already initialized");
        owner = creator;
        allowlistedDestinationChains[_chainSelector] = true;
        allowlistedSourceChains[_chainSelector] = true;
        rewardTokenAddress = _rewardTokenAddress;
        mintPriceInGHO = _mintPriceInGHO;
        minimumMintAmount = _minimumMintAmount;
        emit OwnershipTransferred(address(0), creator);
        emit Initialized(creator, lensProfileId, moduleAddress, _chainSelector,_rewardTokenAddress);
        return true;
    }

    function testPermit(address _token,uint256 amountInGHO,uint256 deadline,uint8 v,bytes32 r,bytes32 s) external {
        IERC20Permit(_token).permit(msg.sender, address(this), amountInGHO, deadline, v, r, s);
        IERC20(_token).transferFrom(msg.sender, address(this), amountInGHO);
    }

    function subscribe(uint256 lensProfileId, uint256 amountInGHO,uint256 deadline,uint8 v,bytes32 r,bytes32 s) external {
        require(lensProfileId!=0,"Lens Profile Id cannot be 0");
        require(amountInGHO>=minimumMintAmount,"Amount is less than minimum mint amount");

        IERC20Permit(rewardTokenAddress).permit(msg.sender, address(this), amountInGHO, deadline, v, r, s);
        IERC20(rewardTokenAddress).transferFrom(msg.sender, address(this), amountInGHO);

        uint256 _totalMintAmount=amountInGHO/mintPriceInGHO;

        bytes memory _data=abi.encode(lensProfileId,_totalMintAmount,msg.sender);

        uint256 _fee=vaultFactory.getFee(POLYGON_CHAIN_SELECTOR,_data);

        require(s_linkToken.balanceOf(address(this))>=_fee,"Not enough LINK Balance");

        s_linkToken.transferFrom(address(this),address(vaultFactory),_fee);
        
        bytes32 _messageId=vaultFactory.subscribe(POLYGON_CHAIN_SELECTOR,_data);

        // handle adding stake balance in the contract state

        emit SubscriptionInitiated(_messageId, msg.sender, lensProfileId, amountInGHO, _totalMintAmount);
    }
    
    // Chainlink CCIP functions

    /// handle a received message
    function _ccipReceive(
        Client.Any2EVMMessage memory any2EvmMessage
    )
        internal
        override
        onlyAllowlisted(
            any2EvmMessage.sourceChainSelector,
            abi.decode(any2EvmMessage.sender, (address))
        ) // Make sure source chain and sender are allowlisted
    {
        s_lastReceivedMessageId = any2EvmMessage.messageId; // fetch the messageId
        s_lastReceivedData = any2EvmMessage.data; // abi-decoding of the sent data
       

        emit MessageReceived(
            any2EvmMessage.messageId,
            any2EvmMessage.sourceChainSelector, // fetch the source chain identifier (aka selector)
            abi.decode(any2EvmMessage.sender, (address)), // abi-decoding of the sender address,
            any2EvmMessage.data
        );
    }

    /// @notice Fetches the details of the last received message.
    /// @return messageId The ID of the last received message.
    /// @return data The last received data.
    function getLastReceivedMessageDetails()
        external
        view
        returns (bytes32 messageId, bytes memory data)
    {
        return (s_lastReceivedMessageId, s_lastReceivedData);
    }


    // Funds Recovery functions

    /// @notice Fallback function to allow the contract to receive Ether.
    /// @dev This function has no function body, making it a default function for receiving Ether.
    /// It is automatically called when Ether is sent to the contract without any data.
    receive() external payable {}

    /// @notice Allows the contract owner to withdraw the entire balance of Ether from the contract.
    /// @dev This function reverts if there are no funds to withdraw or if the transfer fails.
    /// It should only be callable by the owner of the contract.
    /// @param _beneficiary The address to which the Ether should be sent.
    function withdraw(address _beneficiary) public onlyOwner {
        // Retrieve the balance of this contract
        uint256 amount = address(this).balance;

        // Revert if there is nothing to withdraw
        if (amount == 0) revert NothingToWithdraw();

        // Attempt to send the funds, capturing the success status and discarding any return data
        (bool sent, ) = _beneficiary.call{value: amount}("");

        // Revert if the send failed, with information about the attempted transfer
        if (!sent) revert FailedToWithdrawEth(msg.sender, _beneficiary, amount);
    }

    /// @notice Allows the owner of the contract to withdraw all tokens of a specific ERC20 token.
    /// @dev This function reverts with a 'NothingToWithdraw' error if there are no tokens to withdraw.
    /// @param _beneficiary The address to which the tokens will be sent.
    /// @param _token The contract address of the ERC20 token to be withdrawn.
    function withdrawToken(
        address _beneficiary,
        address _token
    ) public onlyOwner {
        // Retrieve the balance of this contract
        uint256 amount = IERC20(_token).balanceOf(address(this));

        // Revert if there is nothing to withdraw
        if (amount == 0) revert NothingToWithdraw();

        IERC20(_token).transfer(_beneficiary, amount);
    }

    // Read Functions
}