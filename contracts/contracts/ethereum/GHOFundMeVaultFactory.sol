// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Create2.sol";

import "../interface/IGHOFundMeVault.sol";

error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); // Used to make sure contract has enough balance.
error NothingToWithdraw(); // Used when trying to withdraw Ether but there's nothing to withdraw.
error FailedToWithdrawEth(address owner, address target, uint256 value); // Used when the withdrawal of Ether fails.
error DestinationChainNotAllowlisted(uint64 destinationChainSelector); // Used when the destination chain has not been allowlisted by the contract owner.
error SourceChainNotAllowlisted(uint64 sourceChainSelector); // Used when the source chain has not been allowlisted by the contract owner.
error SenderNotAllowlisted(address sender); // Used when the sender has not been allowlisted by the contract owner.



contract GHOFundMeVaultFactory is CCIPReceiver{
    
    struct Vault{
        uint256 fanTokenId;
        uint256 creatorLensProfileId;
        address moduleAddress;
        address vaultAddress;
        address creator;
        uint64 sourceChainSelector;
        bool exists;
    }

    struct CrosschainMessage{
        uint256 fanTokenId;
        uint256 creatorLensProfileId;
        address creatorAddress;
        uint256 mintPriceInGHO;
        uint256 minimumMintAmount;
    }   

    address public vaultImplementation;
    address public owner;
    address public moduleAddress;
    mapping(address => Vault) private vaults;

    IERC20 private s_linkToken;
    bytes32 private s_lastReceivedMessageId; // Store the last received messageId.
    bytes private s_lastReceivedData; // Store the last received data.

    // The address of the GHO token in Sepolia.
    address public constant GHO_TOKEN_ADDRESS=0xc4bF5CbDaBE595361438F8c6a187bDc330539c60;

    // Chain Selector for Sepolia
    uint64 public SEPOLIA_CHAIN_SELECTOR=16015286601757825753;

    // Chain Selector for Mumbai
    uint64 public POLYGON_CHAIN_SELECTOR=12532609583862916517;

    // Mapping to keep track of allowlisted destination chains.
    mapping(uint64 => bool) public allowlistedDestinationChains;

    // Mapping to keep track of allowlisted source chains.
    mapping(uint64 => bool) public allowlistedSourceChains;

    // Mapping to keep track of allowlisted senders.
    mapping(address => bool) public allowlistedSenders;

    constructor(address _vaultImplementation,address _router, address _link,address _moduleAddress) CCIPReceiver(_router) {
        vaultImplementation = _vaultImplementation;
        s_linkToken = IERC20(_link);
        allowlistedDestinationChains[POLYGON_CHAIN_SELECTOR] = true;
        allowlistedSourceChains[POLYGON_CHAIN_SELECTOR] = true;
        allowlistedSenders[_moduleAddress]=true;
        moduleAddress=_moduleAddress;
        owner=msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }
    
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event VaultDeployed(address indexed _crossChainMessage);


    // Modifers

    /// @dev Modifier that checks if the sender is the owner of the contract.
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyVault()
    {
        require(vaults[msg.sender].exists,"Vault not deployed");
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

    // @notice Allow the contract owner to add the cross chain module address that can deploy a vault. NOT FOR PRODUCTIION!
    /// @param _moduleAddress The address of the module to be allowlisted.
    function addModuleAddress(address _moduleAddress) public onlyOwner{
        allowlistedSenders[_moduleAddress]=true;
        moduleAddress=_moduleAddress;
    }

    // Contract Functions

    // @notice Internal Function that deploys a vault on receiving a CCIP message from GHOFundMe module.
    function _deployVault(
        CrosschainMessage memory _crossChainMessage,
        address _moduleAddress,
        uint64 _chainSelector
    ) internal returns (address _vaultAddress) {
        _vaultAddress=_deployProxy(vaultImplementation,_crossChainMessage.creatorLensProfileId);
        vaults[_crossChainMessage.creatorAddress] = Vault(_crossChainMessage.fanTokenId,_crossChainMessage.creatorLensProfileId,_moduleAddress,_vaultAddress,_crossChainMessage.creatorAddress,_chainSelector,true);
        require(IGHOFundMeVault(_vaultAddress).initialize(_crossChainMessage.creatorAddress, _crossChainMessage.creatorLensProfileId, _moduleAddress, GHO_TOKEN_ADDRESS,_crossChainMessage.mintPriceInGHO,_crossChainMessage.minimumMintAmount,_chainSelector));
    }
    
    function _deployProxy(
        address implementation,
        uint salt
    ) internal returns (address _contractAddress) {
        bytes memory code = _creationCode(implementation, salt);
        _contractAddress = Create2.computeAddress(
            bytes32(salt),
            keccak256(code)
        );
        if (_contractAddress.code.length != 0) return _contractAddress;

        _contractAddress = Create2.deploy(0, bytes32(salt), code);
    }

    function _creationCode(
        address implementation_,
        uint256 salt_
    ) internal pure returns (bytes memory) {
        return
            abi.encodePacked(
                hex"3d60ad80600a3d3981f3363d3d373d3d3d363d73",
                implementation_,
                hex"5af43d82803e903d91602b57fd5bf3",
                abi.encode(salt_)
            );
    }

    function subscribe(uint64 _destinationChainSelector,bytes memory _data) external onlyVault returns(bytes32) {
        return _sendMessagePayLINK(_destinationChainSelector, moduleAddress, _data);
    }


    // Chainlink CCIP functions

    // @notice Sends data to receiver on the destination chain.
    /// @notice Pay for fees in LINK.
    /// @dev Assumes your contract has sufficient LINK.
    /// @param _destinationChainSelector The identifier (aka selector) for the destination blockchain.
    /// @param _receiver The address of the recipient on the destination blockchain.
    /// @param _data The data that is sent cross-chain.
    /// @return messageId The ID of the CCIP message that was sent.
    function _sendMessagePayLINK(
        uint64 _destinationChainSelector,
        address _receiver,
        bytes memory _data
    )
        internal
        returns (bytes32 messageId)
    {
        // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
        Client.EVM2AnyMessage memory evm2AnyMessage = _buildCCIPMessage(
            _receiver,
            _data,
            address(s_linkToken)
        );

        // Initialize a router client instance to interact with cross-chain router
        IRouterClient router = IRouterClient(this.getRouter());

        // Get the fee required to send the CCIP message
        uint256 fees = router.getFee(_destinationChainSelector, evm2AnyMessage);

        if (fees > s_linkToken.balanceOf(address(this)))
            revert NotEnoughBalance(s_linkToken.balanceOf(address(this)), fees);

        // approve the Router to transfer LINK tokens on contract's behalf. It will spend the fees in LINK
        s_linkToken.approve(address(router), fees);

        // Send the CCIP message through the router and store the returned CCIP message ID
        messageId = router.ccipSend(_destinationChainSelector, evm2AnyMessage);

        // Emit an event with message details
        emit MessageSent(
            messageId,
            _destinationChainSelector,
            _receiver,
            _data,
            address(s_linkToken),
            fees
        );

        // Return the CCIP message ID
        return messageId;
    }

    /// @notice Construct a CCIP message.
    /// @dev This function will create an EVM2AnyMessage struct with all the necessary information for sending a data.
    /// @param _receiver The address of the receiver.
    /// @param _data The raw data to be sent.
    /// @param _feeTokenAddress The address of the token used for fees. Set address(0) for native gas.
    /// @return Client.EVM2AnyMessage Returns an EVM2AnyMessage struct which contains information for sending a CCIP message.
    function _buildCCIPMessage(
        address _receiver,
        bytes memory _data,
        address _feeTokenAddress
    ) internal pure returns (Client.EVM2AnyMessage memory) {
        // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
        return
            Client.EVM2AnyMessage({
                receiver: abi.encode(_receiver), // ABI-encoded receiver address
                data: abi.encode(_data), // ABI-encoded string
                tokenAmounts: new Client.EVMTokenAmount[](0), // Empty array aas no tokens are transferred
                extraArgs: Client._argsToBytes(
                    // Additional arguments, setting gas limit
                    Client.EVMExtraArgsV1({gasLimit: 200_000})
                ),
                // Set the feeToken to a feeTokenAddress, indicating specific asset will be used for fees
                feeToken: _feeTokenAddress
            });
    }

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
        CrosschainMessage memory _crosschainMessage=abi.decode(any2EvmMessage.data, (CrosschainMessage));
        address _moduleAddress=abi.decode(any2EvmMessage.sender, (address));
        address _deployedVault=_deployVault(_crosschainMessage,_moduleAddress,any2EvmMessage.sourceChainSelector);
        emit VaultDeployed(_deployedVault);
        emit MessageReceived(
            any2EvmMessage.messageId,
            any2EvmMessage.sourceChainSelector, // fetch the source chain identifier (aka selector)
            abi.decode(any2EvmMessage.sender, (address)), // abi-decoding of the sender address,
            any2EvmMessage.data
        );
    }

    function getFee(uint64 _destinationChainSelector,bytes memory _data) external view returns(uint256)
    {
        return _getFee(_destinationChainSelector, _data);
    }

    function _getFee(uint64 _destinationChainSelector,bytes memory _data) internal view returns(uint256)
    {
        IRouterClient router = IRouterClient(this.getRouter());
        Client.EVM2AnyMessage memory evm2AnyMessage = _buildCCIPMessage(
            moduleAddress,
            _data,
            address(s_linkToken)
        );
        return router.getFee(_destinationChainSelector, evm2AnyMessage);
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

}