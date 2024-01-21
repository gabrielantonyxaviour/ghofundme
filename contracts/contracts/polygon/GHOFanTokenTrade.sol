// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GHOFanTokenTrade is ERC1155URIStorage, Ownable {

    struct Token {
        uint256 tokenId;
        string name;
        string symbol;
        string uri;
        address creator;
    }

    uint256 private tokenIdCounter;
    address private immutable i_ghoFundMeModule;

    string constant public  NAME = "GhoFanTokenTrade";
    string constant public  VERSION = "v0.0.1";

    mapping(uint256 => Token) private _tokens;

    constructor(address ghoFundMeModule) ERC1155("") {
        i_ghoFundMeModule = ghoFundMeModule;
        _transferOwnership(ghoFundMeModule);
    }

    function createToken(string memory name,string memory symbol,string memory uri, address creator,uint256 tokenId) external onlyOwner returns (uint256) {
        _tokens[tokenId] = Token(tokenId,name, symbol, uri, creator);
        _setURI(tokenId, uri);
        return tokenId;
    }

    function mintToken(uint256 tokenId,uint256 amount,address recipient) external onlyOwner {
        _mint(recipient, tokenId, amount, "");
    }

    function burnToken(uint256 tokenId,uint256 amount,address recipient) external onlyOwner {
        _burn(recipient, tokenId, amount);
    }

    function getToken(uint256 tokenId) external view returns (Token memory) {
        return _tokens[tokenId];
    }

    function getModuleAddress() external view returns (address) {
        return i_ghoFundMeModule;
    }

    function totalSupply() public view returns (uint256) {
        return tokenIdCounter;
    }
}