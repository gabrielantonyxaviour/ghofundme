// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


interface IGHOFundMeVault {
    function initialize(address creator, uint256 lensProfileId,address moduleAddress,address rewardTokenAddress, uint256 mintPriceInGHO,uint256 minimumMintAmount,uint64 chainSelector) external returns(bool);
}