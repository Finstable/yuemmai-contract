//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IMarketImpl {
    function swapExactInput(
        address market,
        address srcToken,
        address destToken,
        uint256 amountIn,
        uint256 amountOutMin,
        address beneficiary,
        uint256 deadline
    ) external returns (uint256);

    function swapExactOutput(
        address market,
        address srcToken,
        address destToken,
        uint256 amountOut,
        uint256 amountInMax,
        address beneficiary,
        uint256 deadline
    ) external returns (uint256);
}
