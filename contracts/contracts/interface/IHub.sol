// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IHub{

    function ownerOf(uint256 tokenId) external view returns(address);
}