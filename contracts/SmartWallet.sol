// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./interfaces/IEToken.sol";
import "./interfaces/IMarket.sol";

contract SmartWallet {
    bool public initialized = false;
    uint256 public balance;
    address public owner;
    address public sender;
    address public euler;
    IEToken public eToken;

    // IEToken(0x4ea65A17ddF15a5607e74a2B910268182e140957);

    function init(
        address user,
        address _eToken,
        address _euler
    ) external {
        sender = msg.sender;
        require(!initialized, "Contract already initialized");
        owner = user;
        eToken = IEToken(_eToken);
        euler = _euler;
        initialized = true;
    }

    function handleEnterMarket(address underlying) internal {
        IMarket market = IMarket(0x3419a9C22F665d61ED964Ec999Fc633d00755e55);
        market.enterMarket(0, underlying);
    }

    function deposit(uint256 depositAmount, address underlyingToken)
        public
        returns (uint256 res)
    {
        IERC20(underlyingToken).approve(address(euler), depositAmount);

        handleEnterMarket(address(underlyingToken));

        balance = eToken.balanceOf(address(this));

        eToken.deposit(0, depositAmount);

        // (bool success, bytes memory data) = address(eToken).delegatecall(
        //     abi.encodeWithSignature(
        //         "deposit(uint256,uint256)",
        //         0,
        //         depositAmount
        //     )
        // );

        // The nested xcall
        uint256 curr_balance = eToken.balanceOf(address(this));

        res = curr_balance - balance;
        balance = curr_balance;

        return res;
    }
}
