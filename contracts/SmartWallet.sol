// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./interfaces/IEToken.sol";

import "./interfaces/IDToken.sol";
import "./interfaces/IMarket.sol";

contract SmartWallet {
    bool public initialized = false;

    address public owner;
    address public sender;
    address public euler;

    function init(address user, address _euler) external {
        sender = msg.sender;
        require(!initialized, "Contract already initialized");
        owner = user;

        euler = _euler;
        initialized = true;
    }

    function handleEnterMarket(address underlying) internal {
        IMarket market = IMarket(0xe80eAef1F2807D6a1AEe0d9AA0E2449D374A5E3f);
        market.enterMarket(0, underlying);
    }

    function deposit(
        uint256 depositAmount,
        address underlyingToken,
        address eToken
    ) public returns (uint256 res, uint256) {
        IERC20(underlyingToken).approve(address(euler), depositAmount);

        handleEnterMarket(address(underlyingToken));

        uint256 balance = IEToken(eToken).balanceOf(address(this));

        IEToken(eToken).deposit(0, depositAmount);

        // The nested xcall
        uint256 curr_balance = IEToken(eToken).balanceOf(address(this));

        res = curr_balance - balance;

        return (res, depositAmount);
    }

    function withdraw(
        uint256 withdrawAmount,
        // address underlyingToken,
        address eToken
    ) public returns (uint256 res, uint256) {
        uint256 balance = IEToken(eToken).balanceOf(address(this));

        IEToken(eToken).withdraw(0, withdrawAmount);

        // The nested xcall
        uint256 curr_balance = IEToken(eToken).balanceOf(address(this));

        res = balance - curr_balance;

        return (res, withdrawAmount);
    }

    function borrow(
        uint256 borrowAmount,
        //address underlyingToken,
        address dToken
    ) public returns (uint256 res, uint256) {
        uint256 balance = IEToken(dToken).balanceOf(address(this));

        IDToken(dToken).borrow(0, borrowAmount);

        // The nested xcall
        uint256 curr_balance = IDToken(dToken).balanceOf(address(this));

        res = curr_balance - balance;

        return (res, borrowAmount);
    }

    function repay(
        uint256 repayAmount,
        address underlyingToken,
        address dToken
    ) public returns (uint256 res, uint256) {
        IERC20(underlyingToken).approve(address(euler), repayAmount);

        uint256 balance = IEToken(dToken).balanceOf(address(this));

        IDToken(dToken).repay(0, repayAmount);

        // The nested xcall
        uint256 curr_balance = IDToken(dToken).balanceOf(address(this));

        res = balance - curr_balance;

        return (res, repayAmount);
    }
}
