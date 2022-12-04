// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20Lib is IERC20 {
    function symbol() external view returns (string memory);

    function name() external view returns (string memory);
}
