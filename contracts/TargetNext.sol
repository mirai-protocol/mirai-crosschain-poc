// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./interfaces/IEToken.sol";
import "./interfaces/IClone.sol";
import "./interfaces/ITarget.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract TargetNext is Ownable {
    // IERC20 public underlyingToken =
    //     IERC20(0x2eDdC4D432F0af7c05F9ACf95EBE8b12BD9f83B6);

    //IEToken public eToken = IEToken(0x4ea65A17ddF15a5607e74a2B910268182e140957);

    address public euler = address(0xfd24d165d449aBf880A4Ae75dB2EFfD844f103E6);
    address public sender;
    uint256 public balance;
    address public walletImplementation;

    bool public pong;
    uint256 public res;

    mapping(address => address) public scw;

    event WalletCreated(address _clone, address _user);
    event Deposit(address _token, address _user, uint256 _amount);
    event Withdraw(address _token, address _user, uint256 _amount);
    event Borrow(address _token, address _user, uint256 _amount);
    event Repay(address _token, address _user, uint256 _amount);

    constructor(address _walletImplementation) {
        walletImplementation = _walletImplementation;
    }

    function updateWalletImplementation(address _walletImplementation)
        public
        onlyOwner
    {
        walletImplementation = _walletImplementation;
    }

    function createWallet(address user) public returns (address clone) {
        sender = msg.sender;
        require(user != address(0), "user address is not defined");

        bytes32 salt = keccak256(abi.encodePacked(user));

        clone = Clones.cloneDeterministic(walletImplementation, salt);

        IClone(clone).init(user, address(euler));

        scw[user] = clone;

        emit WalletCreated(clone, user);

        return clone;
    }

    function deposit(
        address underlyingToken,
        address eToken,
        uint256 depositAmount,
        address user
    ) public {
        IERC20(underlyingToken).approve(address(euler), depositAmount);

        if (scw[user] == address(0)) {
            createWallet(user);
        }

        // transfer usdc to scw

        IERC20(underlyingToken).transfer(scw[user], depositAmount);

        res = ITarget(scw[user]).deposit(
            depositAmount,
            address(underlyingToken),
            address(eToken)
        );

        pong = true;

        emit Deposit(address(underlyingToken), user, depositAmount);

        //_depositFor(depositAmount);
    }

    function withdraw(
        address underlyingToken,
        address eToken,
        uint256 withdrawAmount,
        address user
    ) public {
        // IERC20(underlyingToken).approve(address(euler), depositAmount);

        require(scw[user] != address(0), "user address is not defined");

        //IERC20(underlyingToken).transfer(scw[user], depositAmount);

        res = ITarget(scw[user]).withdraw(
            withdrawAmount,
            address(underlyingToken),
            address(eToken)
        );

        emit Withdraw(address(underlyingToken), user, withdrawAmount);
    }

    function borrow(
        address underlyingToken,
        address dToken,
        uint256 borrowAmount,
        address user
    ) public {
        // IERC20(underlyingToken).approve(address(euler), depositAmount);

        require(scw[user] != address(0), "user address is not defined");

        //IERC20(underlyingToken).transfer(scw[user], depositAmount);

        res = ITarget(scw[user]).borrow(
            borrowAmount,
            address(underlyingToken),
            address(dToken)
        );

        emit Borrow(address(underlyingToken), user, borrowAmount);
    }

    function repay(
        address underlyingToken,
        address dToken,
        uint256 repayAmount,
        address user
    ) public {
        // IERC20(underlyingToken).approve(address(euler), depositAmount);

        require(scw[user] != address(0), "user address is not defined");

        //IERC20(underlyingToken).transfer(scw[user], depositAmount);

        res = ITarget(scw[user]).repay(
            repayAmount,
            address(underlyingToken),
            address(dToken)
        );

        emit Repay(address(underlyingToken), user, repayAmount);
    }
}
