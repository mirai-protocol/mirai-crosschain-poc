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
import "./interfaces/IPUSHCommInterface.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./interfaces/IERC20Lib.sol";

contract TargetNext is IXReceiver, Ownable {
    IConnext public connext =
        IConnext(0x173d82FF0294d4bb83A3AAF30Be958Cbc6D809f7);

    address public euler = address(0x351e3ccF908C63c9f13c79af85d4961335F05Be1);
    address public Esource;
    address public Dsource;

    address public EPNS_COMM_CONTRACT =
        address(0xb3971BCef2D791bc4027BbfedFb47319A4AAaaAa);

    address public Channel =
        address(0x4274A49FBeB724D75b8ba7bfC55FC8495A15AD1E);

    address public walletImplementation;

    mapping(address => address) public scw; // smart contract wallet

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

        // transfer usdc to scw(smart contract wallet)

        IERC20(underlyingToken).transfer(scw[user], depositAmount);

        (uint256 res, uint256 amount) = ITarget(scw[user]).deposit(
            depositAmount,
            address(underlyingToken),
            address(eToken)
        );

        sendPong(res, amount, uint8(0));

        emit Deposit(address(underlyingToken), user, depositAmount);
    }

    function withdraw(
        address underlyingToken,
        address eToken,
        uint256 withdrawAmount,
        address user
    ) public {
        require(scw[user] != address(0), "user address is not defined");

        (uint256 res, uint256 amount) = ITarget(scw[user]).withdraw(
            withdrawAmount,
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
        require(scw[user] != address(0), "user address is not defined");

        (uint256 res, uint256 amount) = ITarget(scw[user]).borrow(
            borrowAmount,
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
            uint256 amount,
            address user,
            uint8 flag
        ) = abi.decode(_callData, (address, address, uint256, address, uint8));

        // flag=0 is for deposit
        if (flag == 0) {
            deposit(underlyingToken, token, amount, user);

            IPUSHCommInterface(EPNS_COMM_CONTRACT).sendNotification(
                Channel,
                user, // to recipient,
                bytes(
                    string(
                        abi.encodePacked(
                            "0",
                            "+", // segregator
                            "3",
                            "+", // segregator
                            "Deposited in Mirai Protocol", // this is notificaiton title.
                            "+", // segregator
                            formatStringNotification(0, amount, underlyingToken) // notification body
                        )
                    )
                )
            );

            // flag=1 is for withdraw
        } else if (flag == 1) {
            withdraw(underlyingToken, token, amount, user);

            IPUSHCommInterface(EPNS_COMM_CONTRACT).sendNotification(
                Channel,
                user, // to recipient,
                bytes(
                    string(
                        abi.encodePacked(
                            "0",
                            "+", // segregator
                            "3",
                            "+", // segregator
                            "Withdrawn in Mirai Protocol", // this is notificaiton title.
                            "+", // segregator
                            formatStringNotification(1, amount, underlyingToken) // notification body
                        )
                    )
                )
            );

            // flag=2 is for borrow
        } else if (flag == 2) {
            borrow(underlyingToken, token, amount, user);

            IPUSHCommInterface(EPNS_COMM_CONTRACT).sendNotification(
                Channel,
                user, // to recipient,
                bytes(
                    string(
                        abi.encodePacked(
                            "0",
                            "+", // segregator
                            "3",
                            "+", // segregator
                            "Borrowed from Mirai Protocol", // this is notificaiton title.
                            "+", // segregator
                            formatStringNotification(2, amount, underlyingToken) // notification body
                        )
                    )
                )
            );
            // flag=3 is for repay
        } else if (flag == 3) {
            repay(underlyingToken, token, amount, user);

            IPUSHCommInterface(EPNS_COMM_CONTRACT).sendNotification(
                Channel,
                user, // to recipient,
                bytes(
                    string(
                        abi.encodePacked(
                            "0",
                            "+", // segregator
                            "3",
                            "+", // segregator
                            "Repayed on Mirai Protocol", // this is notificaiton title.
                            "+", // segregator
                            formatStringNotification(3, amount, underlyingToken) // notification body
                        )
                    )
                )
            );
        } else {
            revert("Invalid flag");
        }
    }

    function sendPong(
        uint256 TokenAmount,
        uint256 amount,
        uint8 flag
    ) public payable {
        bytes memory callData = abi.encode(TokenAmount, amount, flag);

        // flag=0 is for deposit and flag=1 is for withdraw
        if (flag == 0 || flag == 1) {
            connext.xcall{value: 0}(
                1735353714, // _destination: Domain ID of the destination chain
                Esource, // Esource: address of the Esource contract
                address(0), // _asset: address of the token contract
                msg.sender, // _delegate: address that can revert or forceLocal on destination
                0, // _amount: amount of tokens to transfer
                0, // _slippage: the maximum amount of slippage the user will accept in BPS, in this case 0.3%
                callData // _callData: the encoded calldata to send
            );
        }

        // flag=2 is for borrow and flag=3 is for repay

        if (flag == 2 || flag == 3) {
            connext.xcall{value: 0}(
                1735353714, // _destination: Domain ID of the destination chain
                Dsource, // Dsource: address of the Dsource contract
                address(0), // _asset: address of the token contract
                msg.sender, // _delegate: address that can revert or forceLocal on destination
                0, // _amount: amount of tokens to transfer
                0, // _slippage: the maximum amount of slippage the user will accept in BPS, in this case 0.3%
                callData // _callData: the encoded calldata to send
            );
        }
    }

    function formatStringNotification(
        uint8 flag,
        uint256 amount,
        address underlyingToken
    ) internal view returns (string memory) {
        // flag=0 is for deposit
        if (flag == uint8(0)) {
            return
                string.concat(
                    "Deposit for",
                    " ",
                    Strings.toString(amount),
                    " ",
                    IERC20Lib(underlyingToken).symbol(),
                    " ",
                    "on Mumbai Successful"
                );
            // flag=1 is for withdraw
        } else if (flag == uint8(1)) {
            return
                string.concat(
                    "Withdraw for",
                    " ",
                    Strings.toString(amount),
                    " ",
                    IERC20Lib(underlyingToken).symbol(),
                    " ",
                    "on Mumbai Successful"
                );
        }
        // flag=2 is for borrow
        if (flag == uint8(2)) {
            return
                string.concat(
                    "Borrow for",
                    " ",
                    Strings.toString(amount),
                    " ",
                    IERC20Lib(underlyingToken).symbol(),
                    " ",
                    "on Mumbai Successful"
                );
            // flag=2 is for repay
        } else if (flag == uint8(3)) {
            return
                string.concat(
                    "Repayment for",
                    " ",
                    Strings.toString(amount),
                    " ",
                    IERC20Lib(underlyingToken).symbol(),
                    " ",
                    "on Mumbai Successful"
                );
        } else {
            revert("invalid flag");
        }
    }
}
