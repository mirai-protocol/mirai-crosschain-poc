// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDToken is IERC20 {
    function borrow(uint256 subAccountId, uint256 amount) external;

    function repay(uint256 subAccountId, uint256 amount) external;
}
