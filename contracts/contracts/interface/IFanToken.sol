// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


interface IFanToken {

    function createToken(string memory name,string memory symbol,string memory uri, address creator,uint256 tokenId) external;

    function mintToken(uint256 tokenId,uint256 amount,address recipient) external;

    function burnToken(uint256 tokenId,uint256 amount,address recipient) external;

    function balanceOf(address account, uint256 id) external view returns (uint256);
}