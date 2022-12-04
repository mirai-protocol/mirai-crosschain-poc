// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ITarget {
    function deposit(uint256 depositAmount, address underlyingToken)
        external
        returns (uint256);
}
