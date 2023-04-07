//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11;

interface ILendingLiquidate {
    function liquidateBorrow(
        uint256 input,
        uint256 minReward,
        uint256 deadline,
        address borrower,
        address payable sender
    ) external payable returns (uint256);
}
