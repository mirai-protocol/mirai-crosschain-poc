// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import "@connext/nxtp-contracts/contracts/core/connext/interfaces/IXReceiver.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IPUSHCommInterface.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./interfaces/IERC20Lib.sol";

contract ESource is IXReceiver, ERC20, ERC20Burnable, Ownable {
    // The connext contract on the origin domain
    IConnext public immutable connext;
    address public eToken = address(0x4ea65A17ddF15a5607e74a2B910268182e140957);
    address public current_user;
    bool public comeback;

    // The canonical TEST Token on Goerli
    IERC20Lib public underlyingToken =
        IERC20Lib(0x07865c6E87B9F70255377e024ace6630C1Eaa37F); //usdc

    address public underlyingToken1 =
        address(0x2eDdC4D432F0af7c05F9ACf95EBE8b12BD9f83B6);

    address public EPNS_COMM_CONTRACT =
        address(0xb3971BCef2D791bc4027BbfedFb47319A4AAaaAa);

    address public Channel =
        address(0x4274A49FBeB724D75b8ba7bfC55FC8495A15AD1E);

    constructor(IConnext _connext) ERC20("Mirai circle USD", "mUSDC") {
        connext = _connext;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function formatStringNotification(uint8 flag, uint256 amount)
        internal
        view
        returns (string memory)
    {
        if (flag == uint8(0)) {
            return
                string.concat(
                    Strings.toString(amount),
                    " ",
                    "eUSDC",
                    " ",
                    "minted on Goerli"
                );
        } else if (flag == uint8(1)) {
            return
                string.concat(
                    Strings.toString(amount),
                    " ",
                    "eUSDC",
                    " ",
                    "burned on Goerli"
                );
        } else {
            revert("invalid flag");
        }
    }

    function formatTitle(uint8 flag, address token)
        internal
        view
        returns (string memory)
    {
        if (flag == 0) {
            return string.concat("eUSDC", " ", "Minted");
        } else if (flag == 1) {
            return string.concat("eUSDC", " ", "Burned");
        } else {
            revert("invalid flag");
        }
    }

    function deposit(
        address target,
        uint32 destinationDomain,
        uint256 depositAmount,
        uint256 relayerFee
    ) external {
        current_user = msg.sender;
        // User sends funds to this contract
        underlyingToken.transferFrom(msg.sender, address(this), depositAmount);

        // Encode the data needed for the target contract call.
        bytes memory callData = abi.encode(
            underlyingToken1,
            eToken,
            depositAmount,
            current_user,
            uint8(0)
        );

        connext.xcall{value: relayerFee}(
            destinationDomain, // _destination: Domain ID of the destination chain
            target, // _to: address of the target contract
            address(0), // _asset: address of the token contract
            msg.sender, // _delegate: address that can revert or forceLocal on destination
            0, // _amount: amount of tokens to transfer
            0, // _slippage: the max slippage the user will accept in BPS (0.3%)
            callData // _callData: the encoded calldata to send
        );
    }

    function withdraw(
        address target,
        uint32 destinationDomain,
        uint256 withdrawAmount,
        uint256 relayerFee
    ) external {
        current_user = msg.sender;
        // Encode the data needed for the target contract call.
        bytes memory callData = abi.encode(
            underlyingToken1,
            eToken,
            withdrawAmount,
            current_user,
            uint8(1)
        );

        connext.xcall{value: relayerFee}(
            destinationDomain, // _destination: Domain ID of the destination chain
            target, // _to: address of the target contract
            address(0), // _asset: address of the token contract
            msg.sender, // _delegate: address that can revert or forceLocal on destination
            0, // _amount: amount of tokens to transfer
            0, // _slippage: the max slippage the user will accept in BPS (0.3%)
            callData // _callData: the encoded calldata to send
        );
    }

    /**
     * @notice The receiver function as required by the IXReceiver interface.
     * @dev The "callback" function for this example. Will be triggered after Pong xcalls back.
     */
    function xReceive(
        bytes32 _transferId,
        uint256 _amount,
        address _asset,
        address _originSender,
        uint32 _origin,
        bytes memory _callData
    ) external returns (bytes memory) {
        comeback = true;
        (uint256 TokenAmount, uint256 Amount, uint8 flag) = abi.decode(
            _callData,
            (uint256, uint256, uint8)
        );

        if (flag == uint8(0)) {
            _mint(current_user, TokenAmount);

            IPUSHCommInterface(EPNS_COMM_CONTRACT).sendNotification(
                Channel,
                current_user, // to recipient,
                bytes(
                    string(
                        abi.encodePacked(
                            "0",
                            "+", // segregator
                            "3",
                            "+", // segregator
                            formatTitle(0, eToken), // this is notificaiton title.
                            "+", // segregator
                            formatStringNotification(0, TokenAmount) // notification body
                        )
                    )
                )
            );
        }

        if (flag == uint8(1)) {
            underlyingToken.transfer(current_user, Amount);

            _burn(current_user, TokenAmount);

            IPUSHCommInterface(EPNS_COMM_CONTRACT).sendNotification(
                Channel,
                current_user, // to recipient,
                bytes(
                    string(
                        abi.encodePacked(
                            "0",
                            "+", // segregator
                            "3",
                            "+", // segregator
                            formatTitle(1, eToken), // this is notificaiton title.
                            "+", // segregator
                            formatStringNotification(1, TokenAmount) // notification body
                        )
                    )
                )
            );
        }
    }
}
