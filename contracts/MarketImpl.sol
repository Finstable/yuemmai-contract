//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./modules/amm/interfaces/IUniswapRouter02.sol";
import "./modules/kap20/interfaces/IKAP20.sol";
import "./interfaces/IMarketImpl.sol";

contract MarketImpl is IMarketImpl {
    function swapExactInput(
        address market,
        address srcToken,
        address destToken,
        uint256 amountIn,
        uint256 amountOutMin,
        address beneficiary,
        uint256 deadline
    ) external override returns (uint256) {
        address[] memory path = new address[](2);
        uint256[] memory amounts;

        path[0] = srcToken;
        path[1] = destToken;

        IUniswapRouter02 router = IUniswapRouter02(market);
        IKAP20(srcToken).approve(address(router), amountIn);

        amounts = router.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            beneficiary,
            deadline
        );

        return amounts[amounts.length - 1];
    }

    function swapExactOutput(
        address market,
        address srcToken,
        address destToken,
        uint256 amountOut,
        uint256 amountInMax,
        address beneficiary,
        uint256 deadline
    ) external override returns (uint256) {
        address[] memory path = new address[](2);
        uint256[] memory amounts;

        path[0] = srcToken;
        path[1] = destToken;

        IUniswapRouter02 router = IUniswapRouter02(market);
        IKAP20(srcToken).approve(address(router), amountInMax);

        amounts = router.swapTokensForExactTokens(
            amountOut,
            amountInMax,
            path,
            beneficiary,
            deadline
        );

        return amounts[amounts.length - 1];
    }
}
