// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ITarget {
    function deposit(
        uint256 depositAmount,
        address underlyingToken,
        address eToken
    ) external returns (uint256);

    function withdraw(
        uint256 withdrawAmount,
        address underlyingToken,
        address eToken
    ) external returns (uint256);

    function borrow(
        uint256 borrowAmount,
        address underlyingToken,
        address dToken
    ) external returns (uint256);

    function repay(
        uint256 repayAmount,
        address underlyingToken,
        address dToken
    ) external returns (uint256);
}
