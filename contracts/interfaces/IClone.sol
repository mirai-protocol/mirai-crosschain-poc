// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IClone {
    function init(
        address user,
        address eToken,
        address euler
    ) external;
}
