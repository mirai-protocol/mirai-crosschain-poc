// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./interfaces/IEToken.sol";
import "./interfaces/IClone.sol";
import "./interfaces/ITarget.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract TargetNext is Ownable {
    IERC20 public underlyingToken =
        IERC20(0x2eDdC4D432F0af7c05F9ACf95EBE8b12BD9f83B6);

    IEToken public eToken = IEToken(0x4ea65A17ddF15a5607e74a2B910268182e140957);
    address public source = address(0x985D36be8Ed36DBA7037334EEB338df3c634fff7);
    address public euler = address(0xfd24d165d449aBf880A4Ae75dB2EFfD844f103E6);
    address public sender;
    uint256 public balance;
    address public walletImplementation;
    // bool public received;
    // bool public afterdeposit;
    // string public greeting;
    bool public pong;
    uint256 public res;

    mapping(address => address) public scw;

    event WalletCreated(address clone, address user);

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

        IClone(clone).init(user, address(eToken), address(euler));

        scw[user] = clone;

        emit WalletCreated(clone, user);

        return clone;
    }

    function deposit(address user, uint256 depositAmount) public {
        underlyingToken.approve(address(euler), depositAmount);

        if (scw[user] == address(0)) {
            createWallet(user);
        }

        res = ITarget(scw[user]).deposit(
            depositAmount,
            address(underlyingToken)
        );

        pong = true;

        //_depositFor(depositAmount);
    }
}