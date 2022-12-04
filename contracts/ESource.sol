// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import "@connext/nxtp-contracts/contracts/core/connext/interfaces/IXReceiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ESource is IXReceiver, ERC20, Ownable {
    // The connext contract on the origin domain
    IConnext public immutable connext;
    address public current_user;
    bool public comeback;

    // The canonical TEST Token on Goerli
    IERC20 public underlyingToken =
        IERC20(0x07865c6E87B9F70255377e024ace6630C1Eaa37F); //usdc

    constructor(IConnext _connext) ERC20("Mirai circle USD", "mUSDC") {
        connext = _connext;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
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
            depositAmount,
            address(current_user),
            uint256(0)
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
        uint256 eTokenAmount = abi.decode(_callData, (uint256));

        _mint(current_user, eTokenAmount);
    }
}

// GOERLI   deposit(100) --> Source(100) --> etoken(100)

// POLYGON   Target-->etoken --> etoken Target(100)

// Source1   borrow-->(100)   Target-->borrow(100)  Target(100 Tokens + x dTokens)

// Source1<-- 100T+xdTokens  --> USER
