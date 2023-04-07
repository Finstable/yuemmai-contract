//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11;

interface ILKAP20Liquidate {
    function liquidateBorrow(
        uint256 input,
        uint256 minReward,
        uint256 deadline,
        address borrower,
        address payable sender
    ) external returns (uint256);

    function underlyingToken() external view returns (address);
}
