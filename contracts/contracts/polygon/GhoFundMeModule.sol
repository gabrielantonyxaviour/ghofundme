// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import "../interface/IFanToken.sol";

import "@openzeppelin/contracts/utils/Create2.sol";
import "../interface/IHub.sol";

import "@aave/lens-protocol/contracts/interfaces/IFollowModule.sol";
import "@aave/lens-protocol/contracts/core/modules/ModuleBase.sol";
import "@aave/lens-protocol/contracts/core/modules/follow/FollowValidatorFollowModuleBase.sol";

error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); // Used to make sure contract has enough balance.
error NothingToWithdraw(); // Used when trying to withdraw Ether but there's nothing to withdraw.
error FailedToWithdrawEth(address owner, address target, uint256 value); // Used when the withdrawal of Ether fails.
error DestinationChainNotAllowlisted(uint64 destinationChainSelector); // Used when the destination chain has not been allowlisted by the contract owner.
error SourceChainNotAllowlisted(uint64 sourceChainSelector); // Used when the source chain has not been allowlisted by the contract owner.
error SenderNotAllowlisted(address sender); // Used when the sender has not been allowlisted by the contract owner.


contract GHOFundMeFollowModule is  FollowValidatorFollowModuleBase, CCIPReceiver {
    struct CreateTokenInputParams{
        string fanMintTokenName;
        string fanTradeTokenName;
        string fanMintTokenSymbol;
        string fanTradeTokenSymbol;
        string mintTokenURI;
        string tradeTokenURI;
        uint256 lensProfileId;
        uint256 mintPriceInGHO;
        uint256 minimumMintAmount;
    }
    struct GHOFundMeAccount{
        uint256 lensProfileId;
        uint256 tokenId;
        address creator;
        address vaultAddress;
        bytes32 createAccountMessageId;
        bool exists;
    }

    struct CrosschainMessage{
        uint256 fanTokenId;
        uint256 creatorLensProfileId;
        address creatorAddress;
        uint256 mintPriceInGHO;
        uint256 minimumMintAmount;
    } 

    // address of Lens Hub in Mumbai Testnet
    address public constant LENS_HUB=0x4fbffF20302F3326B20052ab9C217C44F6480900;

    uint256 private _tokenIdCounter;
    IERC20 private s_linkToken;
    bytes32 private s_lastReceivedMessageId; // Store the last received messageId.
    bytes private s_lastReceivedData; // Store the last received data.
    IFanToken public fanMintToken;
    IFanToken public fanTradeToken;

    // Mapping to keep track of Create GHOFundMe Accounts
    mapping(uint256 =>GHOFundMeAccount) public accounts;

    // Mapping to keep track of allowlisted destination chains.
    mapping(uint64 => bool) public allowlistedDestinationChains;

    // Mapping to keep track of allowlisted source chains.
    mapping(uint64 => bool) public allowlistedSourceChains;

    // Mapping to keep track of allowlisted senders.
    mapping(address => bool) public allowlistedSenders;

    // Chain Selector for Sepolia
    uint64 public SEPOLIA_CHAIN_SELECTOR=16015286601757825753;

    // Chain Selector for Mumbai
    uint64 public POLYGON_CHAIN_SELECTOR=12532609583862916517;

    address public owner;
    string private _moduleMetadataURI;
    address public vaultFactory;
    address public vaultImplementation;

    constructor(address _vaultImplementation, address _router, address _link)  ModuleBase(LENS_HUB) CCIPReceiver(_router){
        allowlistedDestinationChains[SEPOLIA_CHAIN_SELECTOR] = true;
        allowlistedDestinationChains[SEPOLIA_CHAIN_SELECTOR] = true;
        vaultImplementation=_vaultImplementation;
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

    // Event emitted when a new fan token is created
    event FanTokenCreated(bytes32 indexed messageId,address vaultAddress,uint256 tokenId,uint256 lensProfileId,address creator);

    // Event emitted when a fan token is minted
    event MintedFanToken(bytes32 indexed messageId,uint256 lensProfileId,uint256 tokenId,uint256 amount,address subscriber);

    // Event emitted when a fan token is burned
    event BurnedFanToken(bytes32 indexed messageId,uint256 lensProfileId,uint256 tokenId,uint256 amount,address subscriber);

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

    // GHOFundMeModule Functions

    function setVaultFactory(address _vaultFactory) external onlyOwner{
        require(vaultFactory==address(0),"Already initialized");
        vaultFactory=_vaultFactory;
    } 

    function setFanTokens(address mintToken,address tradeToken) external onlyOwner{
        require(mintToken!=address(0),"Invalid mint token");
        require(tradeToken!=address(0),"Invalid trade token");
        require(address(fanMintToken)==address(0)&&address(fanTradeToken)==address(0),"Already initialized");
        fanMintToken=IFanToken(mintToken);
        fanTradeToken=IFanToken(tradeToken);
    }

    function createFanToken(CreateTokenInputParams memory params) external {
        require(IHub(LENS_HUB).ownerOf(params.lensProfileId)==msg.sender,"Invalid Profile");
        require(vaultFactory!=address(0),"vault factory not set");

        address _vaultAddress=getVaultAddress(params.lensProfileId);
        CrosschainMessage memory _message=CrosschainMessage(_tokenIdCounter,params.lensProfileId,msg.sender,params.mintPriceInGHO,params.minimumMintAmount);

        bytes memory _data=abi.encode(_message);
        bytes32 _crosschainMessageId=_sendMessagePayLINK(SEPOLIA_CHAIN_SELECTOR, vaultFactory, _data);
        accounts[params.lensProfileId]=GHOFundMeAccount(params.lensProfileId,_tokenIdCounter,msg.sender,_vaultAddress,_crosschainMessageId,true);

        fanMintToken.createToken(params.fanMintTokenName, params.fanMintTokenSymbol, params.mintTokenURI, msg.sender,_tokenIdCounter);
        fanTradeToken.createToken(params.fanTradeTokenName, params.fanTradeTokenSymbol, params.tradeTokenURI, msg.sender, _tokenIdCounter);
        emit FanTokenCreated(_crosschainMessageId,_vaultAddress,_tokenIdCounter,params.lensProfileId,msg.sender);
        _tokenIdCounter++;
    }
    
    function _mintTokens(bytes32 _messageId,uint256 _lensProfileId, uint256 _totalMintAmount,address _subscriber) internal {
        require(accounts[_lensProfileId].exists,"Invalid lens profile id");
        fanMintToken.mintToken(accounts[_lensProfileId].tokenId, _totalMintAmount, _subscriber);
        fanTradeToken.mintToken(accounts[_lensProfileId].tokenId, _totalMintAmount, _subscriber);
        emit MintedFanToken(_messageId,_lensProfileId,accounts[_lensProfileId].tokenId, _totalMintAmount, _subscriber);
    }

    function terminateSubscription(uint256 _lensProfileId,uint256 _tokenAmount) external{
        require(accounts[_lensProfileId].exists,"Invalid lens profile id");
        require(fanMintToken.balanceOf(msg.sender,accounts[_lensProfileId].tokenId)>=_tokenAmount,"Invalid token amount");
        require(fanTradeToken.balanceOf(msg.sender,accounts[_lensProfileId].tokenId)>=_tokenAmount,"Invalid token amount");

        s_linkToken.transferFrom(msg.sender, address(this), _tokenAmount);
        fanMintToken.burnToken(accounts[_lensProfileId].tokenId, _tokenAmount, msg.sender);
        fanTradeToken.burnToken(accounts[_lensProfileId].tokenId, _tokenAmount, msg.sender);
        bytes memory _data=abi.encode(_lensProfileId,_tokenAmount,msg.sender);
        uint256 _fee=_getFee(_lensProfileId,SEPOLIA_CHAIN_SELECTOR,_data);
        require(s_linkToken.allowance(msg.sender, address(this))>=_fee,"approve LINK for cross chain"); 
        
        bytes32 _messageId=_sendMessagePayLINK(SEPOLIA_CHAIN_SELECTOR, accounts[_lensProfileId].vaultAddress,_data);

        emit BurnedFanToken(_messageId,_lensProfileId,accounts[_lensProfileId].tokenId, _tokenAmount, msg.sender);
    }

    function getVaultAddress(uint256 lensProfileId) public view returns(address _contractAddress)
    {
        bytes memory code = _creationCode(vaultImplementation, lensProfileId);
        _contractAddress = Create2.computeAddress(
            bytes32(lensProfileId),
            keccak256(code)
        );
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

        require(s_linkToken.allowance(msg.sender, address(this))>fees,"approve first");

        s_linkToken.transferFrom(msg.sender, address(this), fees);

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
        (uint256 _lensProfileId,uint256 _totalMintAmount,address _subscriber)=abi.decode(any2EvmMessage.data,(uint256,uint256,address));
        _mintTokens(any2EvmMessage.messageId,_lensProfileId, _totalMintAmount, _subscriber);
        emit MessageReceived(
            any2EvmMessage.messageId,
            any2EvmMessage.sourceChainSelector, // fetch the source chain identifier (aka selector)
            abi.decode(any2EvmMessage.sender, (address)), // abi-decoding of the sender address,
            any2EvmMessage.data
        );
    }

    /// @notice Construct a CCIP message.
    /// @dev This function will create an EVM2AnyMessage struct with all the necessary information for sending a data.
    /// @param _receiver The address of the receiver.
    /// @param _data The raw data to be sent.
    /// @param _feeToken The address of the token used for fees. Set address(0) for native gas.
    /// @return Client.EVM2AnyMessage Returns an EVM2AnyMessage struct which contains information for sending a CCIP message.
    function _buildCCIPMessage(
        address _receiver,
        bytes memory _data,
        address _feeToken
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
                // Set the feeToken to a feeToken, indicating specific asset will be used for fees
                feeToken: _feeToken
            });
    }

    function getFee(uint256 _lensProfileId,uint64 _destinationChainSelector,bytes memory _data) external view returns(uint256)
    {
        return _getFee(_lensProfileId,_destinationChainSelector, _data);
    }

    function _getFee(uint256 _lensProfileId,uint64 _destinationChainSelector,bytes memory _data) internal view returns(uint256)
    {
        IRouterClient router = IRouterClient(this.getRouter());
        Client.EVM2AnyMessage memory evm2AnyMessage = _buildCCIPMessage(
            getVaultAddress(_lensProfileId),
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

    // Lens Module Functions

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