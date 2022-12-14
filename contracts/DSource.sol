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

contract DSource is IXReceiver, ERC20, ERC20Burnable, Ownable {
    // The connext contract on the origin domain
    IConnext public immutable connext;
    address public dToken = address(0x3B0896D332bFd3c71169190668fDe1B89cCA0d22);
    address public currentUser;
    bool public comeback;
    uint256 public currentAmount;

    // The canonical TEST Token on Goerli
    IERC20Lib public underlyingToken =
        IERC20Lib(0x07865c6E87B9F70255377e024ace6630C1Eaa37F); //usdc

    address public underlyingToken1 =
        address(0x2eDdC4D432F0af7c05F9ACf95EBE8b12BD9f83B6);

    address public EPNS_COMM_CONTRACT =
        address(0xb3971BCef2D791bc4027BbfedFb47319A4AAaaAa);

    address public Channel =
        address(0x4274A49FBeB724D75b8ba7bfC55FC8495A15AD1E);

    constructor(IConnext _connext) ERC20("Mirai debt circle USD", "dUSDC") {
        connext = _connext;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function borrow(
        address target,
        uint32 destinationDomain,
        uint256 borrowAmount,
        uint256 relayerFee
    ) external {
        currentUser = msg.sender;

        // Encode the data needed for the target contract call.
        bytes memory callData = abi.encode(
            underlyingToken1,
            dToken,
            borrowAmount,
            currentUser,
            uint8(2)
        );
        currentAmount = borrowAmount;

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

    function repay(
        address target,
        uint32 destinationDomain,
        uint256 repayAmount,
        uint256 relayerFee
    ) public {
        currentUser = msg.sender;

        underlyingToken.transferFrom(currentUser, address(this), repayAmount);

        // Encode the data needed for the target contract call.

        bytes memory callData = abi.encode(
            underlyingToken1,
            dToken,
            repayAmount,
            currentUser,
            uint8(3)
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

        (uint256 tokenAmount, uint256 amount, uint8 flag) = abi.decode(
            _callData,
            (uint256, uint256, uint8)
        );
        // flag=2 is for borrow
        if (flag == uint8(2)) {
            _mint(currentUser, tokenAmount);

            underlyingToken.transfer(currentUser, amount);
        }

        // flag=2 is for borrow
        if (flag == uint8(3)) {
            _burn(currentUser, tokenAmount);
        }
    }
}
