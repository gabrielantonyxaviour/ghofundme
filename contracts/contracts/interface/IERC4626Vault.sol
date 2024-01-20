// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


interface IERC4626Vault {
    function initialize(address creator, uint256 lensProfileId,address moduleAddress,uint64 chainSelector) external returns(bool);
}