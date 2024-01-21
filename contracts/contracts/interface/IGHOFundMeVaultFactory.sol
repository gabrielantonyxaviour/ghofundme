// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


interface IGHOFundMeVaultFactory{


    function subscribe(uint64 _destinationChainSelector,bytes memory _data) external returns(bytes32);

    function getFee(uint64 _destinationChainSelector,bytes memory _data) external view returns(uint256);
}