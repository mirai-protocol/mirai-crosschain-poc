// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@connext/nxtp-contracts/contracts/core/connext/interfaces/IXReceiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import "./interfaces/IEToken.sol";
import "./interfaces/IDToken.sol";
import "./interfaces/IMarket.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Target is IXReceiver, Ownable {
    // The TEST Token on Mumbai
    IERC20 public underlyingToken =
        IERC20(0x2eDdC4D432F0af7c05F9ACf95EBE8b12BD9f83B6);

    // IERC20 public underlyingToken2 =
    //     IERC20(0x2eDdC4D432F0af7c05F9ACf95EBE8b12BD9f83B6); // usdc

    IEToken public eToken = IEToken(0x4ea65A17ddF15a5607e74a2B910268182e140957);
    IDToken public dToken = IDToken(0x2eC2585b83D335ee0721B81e69e8120a9ccd4Be4);
    // The connext contract deployed on the same domain as this contract
    IConnext public connext =
        IConnext(0x173d82FF0294d4bb83A3AAF30Be958Cbc6D809f7);

    uint256 public eBalance;
    uint256 public dBalance;
    address public Esource =
        address(0x955AC5376aD939593CDf1474cE1DF634d445b506);
    address public Dsource =
        address(0xA92cFbCC140902920034F698662F8d6eAFEc3a0D);
    address public euler = address(0xfd24d165d449aBf880A4Ae75dB2EFfD844f103E6);
    address public sender;

    bool public received;
    bool public afterdeposit;
    bool public afterborrow;
    string public greeting;
    bool public pong;

    struct user {
        uint256 usdcSupplied;
        uint256 usdcBorrowed;
        uint256 ethSupplied;
        uint256 ethBorrowed;
        uint256 daiSupplied;
        uint256 daiBorrowed;
    }
    mapping(address => user) public userInfo;

    // constructor(
    //     address _underlyingToken,
    //     address _etoken,
    //     address _source
    // ) {
    //     underlyingToken = IERC20(_underlyingToken);
    //     eToken = IEToken(_etoken);
    //     source = IConnext(source);
    // }

    // constructor() {

    //     handleEnterMarket(0, address(underlyingToken));
    // }

    function transferto(address to, uint256 amount) public onlyOwner {
        underlyingToken.transfer(to, amount);
    }

    function UpdateEsource(address _source) public onlyOwner {
        Esource = _source;
    }

    function UpdateDsource(address _source) public onlyOwner {
        Dsource = _source;
    }

    function UpdateDtoken(address _dtoken) public onlyOwner {
        dToken = IDToken(_dtoken);
    }

    function UpdateEtoken(address _etoken) public onlyOwner {
        eToken = IEToken(_etoken);
    }

    function handleEnterMarket(address underlying) internal {
        IMarket market = IMarket(0x3419a9C22F665d61ED964Ec999Fc633d00755e55);
        market.enterMarket(0, underlying);
    }

    /** @notice The receiver function as required by the IXReceiver interface.
     * @dev The Connext bridge contract will call this function.
     */
    function xReceive(
        bytes32 _transferId,
        uint256 _amount,
        address _asset,
        address _originSender,
        uint32 _origin,
        bytes memory _callData
    ) external returns (bytes memory) {
        // Unpack the _callData

        sender = msg.sender;

        (uint256 Amount, address user, uint256 flag) = abi.decode(
            _callData,
            (uint256, address, uint256)
        );

        if (flag == 0) {
            greeting = "Hello deposit";

            handleEnterMarket(address(underlyingToken));
            underlyingToken.approve(address(euler), Amount);

            received = true;
            _depositFor(Amount);

            userInfo[user].usdcSupplied += Amount;
        } else {
            greeting = "Hello borrow";

            _borrowFor(Amount);

            userInfo[user].usdcBorrowed += Amount;
        }
    }

    function _borrowFor(uint256 _amount) internal {
        // Approve the transfer
        // underlyingToken.approve(address(eToken), _amount);
        dBalance = dToken.balanceOf(address(this));
        // Borrow the tokens
        dToken.borrow(0, _amount);
        afterborrow = true;

        uint256 curr_balance = dToken.balanceOf(address(this));
        sendPong(curr_balance - dBalance, uint8(1));

        //dbalance = curr_balance;
    }

    function _depositFor(uint256 depositAmount) public {
        dBalance = eToken.balanceOf(address(this));

        eToken.deposit(0, depositAmount);

        afterdeposit = true;
        // The nested xcall
        uint256 curr_balance = eToken.balanceOf(address(this));
        sendPong(curr_balance - dBalance, uint8(0));
    }

    function sendPong(uint256 TokenAmount, uint8 flag) public payable {
        bytes memory callData = abi.encode(TokenAmount);

        pong = true;
        //underlyingToken.approve(address(connext), 10 * 1e18);

        if (flag == 0) {
            connext.xcall{value: 0}(
                1735353714, // _destination: Domain ID of the destination chain
                Esource, // _to: address of the target contract (Ping)
                address(0), // _asset: address of the token contract
                msg.sender, // _delegate: address that can revert or forceLocal on destination
                0, // _amount: amount of tokens to transfer
                0, // _slippage: the maximum amount of slippage the user will accept in BPS, in this case 0.3%
                callData // _callData: the encoded calldata to send
            );
        } else {
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

    function giveApproval(address destination, uint256 depositAmount) public {
        underlyingToken.approve(destination, depositAmount);
    }
}
