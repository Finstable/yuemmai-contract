// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

interface IKToken {
    function internalTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function externalTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}