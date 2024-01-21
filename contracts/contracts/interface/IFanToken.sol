// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


interface IFanToken {

    function createToken(string memory name,string memory symbol,string memory uri, address creator,uint256 tokenId) external;
}