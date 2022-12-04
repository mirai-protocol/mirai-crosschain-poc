// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IMarket {
    function enterMarket(uint256 subAccountId, address tokenAddress) external;
}
