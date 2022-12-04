// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@connext/nxtp-contracts/contracts/core/connext/interfaces/IXReceiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import "./interfaces/IEToken.sol";
import "./interfaces/IClone.sol";
import "./interfaces/ITarget.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract TargetNext is IXReceiver, Ownable {
    // IERC20 public underlyingToken =
    //     IERC20(0x2eDdC4D432F0af7c05F9ACf95EBE8b12BD9f83B6);

    //IEToken public eToken = IEToken(0x4ea65A17ddF15a5607e74a2B910268182e140957);

    IConnext public connext =
        IConnext(0x173d82FF0294d4bb83A3AAF30Be958Cbc6D809f7);

    address public euler = address(0xfd24d165d449aBf880A4Ae75dB2EFfD844f103E6);
    address public Esource;
    address public Dsource;

    address public walletImplementation;

    mapping(address => address) public scw;

    event WalletCreated(address _clone, address _user);
    event Deposit(address _token, address _user, uint256 _amount);
    event Withdraw(address _token, address _user, uint256 _amount);
    event Borrow(address _token, address _user, uint256 _amount);
    event Repay(address _token, address _user, uint256 _amount);

    constructor(
        address _walletImplementation,
        address _Esource,
        address _Dsource
    ) {
        walletImplementation = _walletImplementation;
        Esource = _Esource;
        Dsource = _Dsource;
    }

    function updateWalletImplementation(address _walletImplementation)
        public
        onlyOwner
    {
        walletImplementation = _walletImplementation;
    }

    function updateEsource(address _Esource) public onlyOwner {
        Esource = _Esource;
    }

    function updateDsource(address _Dsource) public onlyOwner {
        Dsource = _Dsource;
    }

    function createWallet(address user) public returns (address clone) {
        require(user != address(0), "user address is not defined");

        bytes32 salt = keccak256(abi.encodePacked(user));

        clone = Clones.cloneDeterministic(walletImplementation, salt);

        IClone(clone).init(user, address(euler));

        scw[user] = clone;

        emit WalletCreated(clone, user);

        return clone;
    }

    function xReceive(
        bytes32 _transferId,
        uint256 _amount,
        address _asset,
        address _originSender,
        uint32 _origin,
        bytes memory _callData
    ) external returns (bytes memory) {
        // Unpack the _callData

        (
            address underlyingToken,
            address token,
            uint256 Amount,
            address user,
            uint8 flag
        ) = abi.decode(_callData, (address, address, uint256, address, uint8));

        if (flag == 0) {
            deposit(underlyingToken, token, Amount, user);
        } else if (flag == 1) {
            withdraw(underlyingToken, token, Amount, user);
        } else if (flag == 2) {
            borrow(underlyingToken, token, Amount, user);
        } else if (flag == 3) {
            repay(underlyingToken, token, Amount, user);
        } else {
            revert("Invalid flag");
        }
    }

    function sendPong(
        uint256 TokenAmount,
        uint256 Amount,
        uint8 flag
    ) public payable {
        bytes memory callData = abi.encode(TokenAmount, flag);

        if (flag == 0 || flag == 1) {
            connext.xcall{value: 0}(
                1735353714, // _destination: Domain ID of the destination chain
                Esource, // _to: address of the target contract (Ping)
                address(0), // _asset: address of the token contract
                msg.sender, // _delegate: address that can revert or forceLocal on destination
                0, // _amount: amount of tokens to transfer
                0, // _slippage: the maximum amount of slippage the user will accept in BPS, in this case 0.3%
                callData // _callData: the encoded calldata to send
            );
        }

        if (flag == 2 || flag == 3) {
            connext.xcall{value: 0}(
                1735353714, // _destination: Domain ID of the destination chain
                Dsource, // _to: address of the target contract (Ping)
                address(0), // _asset: address of the token contract
                msg.sender, // _delegate: address that can revert or forceLocal on destination
                0, // _amount: amount of tokens to transfer
                0, // _slippage: the maximum amount of slippage the user will accept in BPS, in this case 0.3%
                callData // _callData: the encoded calldata to send
            );
        }
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

        (uint256 res, uint256 amount) = ITarget(scw[user]).deposit(
            depositAmount,
            address(underlyingToken),
            address(eToken)
        );

        sendPong(res, amount, 0);

        emit Deposit(address(underlyingToken), user, depositAmount);
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

        (uint256 res, uint256 amount) = ITarget(scw[user]).withdraw(
            withdrawAmount,
            address(underlyingToken),
            address(eToken)
        );

        sendPong(res, amount, 1);

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

        (uint256 res, uint256 amount) = ITarget(scw[user]).borrow(
            borrowAmount,
            address(underlyingToken),
            address(dToken)
        );

        sendPong(res, amount, 2);

        emit Borrow(address(underlyingToken), user, borrowAmount);
    }

    function repay(
        address underlyingToken,
        address dToken,
        uint256 repayAmount,
        address user
    ) public {
        require(scw[user] != address(0), "user address is not defined");

        (uint256 res, uint256 amount) = ITarget(scw[user]).repay(
            repayAmount,
            address(underlyingToken),
            address(dToken)
        );

        sendPong(res, amount, 3);

        emit Repay(address(underlyingToken), user, repayAmount);
    }
}
