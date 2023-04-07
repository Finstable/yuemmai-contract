//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./interfaces/ILendingLiquidate.sol";
import "./interfaces/ILKAP20Liquidate.sol";
import "./modules/kap20/interfaces/IKAP20.sol";
import "./modules/amm/interfaces/IUniswapRouter02.sol";

contract LiquidateV1 {
    address owner;
    address public KUBLending;
    uint public returnAmount;
    address public SwapRouter;

    constructor(address _KUBLending, address _SwapRouter) {
        owner = msg.sender;
        KUBLending = _KUBLending;
        SwapRouter = _SwapRouter;
    }

    function KAP20liquidateBorrow(
        ILKAP20Liquidate lending,
        address toSwap,
        uint256 input,
        uint256 minReward,
        uint256 deadline,
        address borrower,
        address liquidator
    ) external returns (uint256) {
        // liquidator transfer input to this contract
        IKAP20 token = IKAP20(lending.underlyingToken());
        token.transferFrom(liquidator, address(this), input);

        // this contract approve lending contract to spend input
        token.approve(address(lending), input);
        // this contract call lending contract to liquidate
        ILKAP20Liquidate(lending).liquidateBorrow(
            input,
            minReward,
            deadline,
            borrower,
            payable(address(this))
        );
        // this contract swap to yes token and transfer to liquidator
        returnAmount = IKAP20(lending.underlyingToken()).balanceOf(
            address(this)
        );

        address[] memory path = new address[](2);
        path[0] = lending.underlyingToken();
        path[1] = toSwap;

        // approve swap router to spend returnAmount
        token.approve(SwapRouter, returnAmount);

        // swap and transfer to liquidator
        IUniswapRouter02(SwapRouter).swapExactTokensForTokens(
            returnAmount,
            minReward,
            path,
            liquidator,
            deadline
        );
    }

    function KUBliquidateBorrow(
        uint256 input,
        uint256 minReward,
        uint256 deadline,
        address borrower
    ) external payable {
        ILendingLiquidate(KUBLending).liquidateBorrow{value: msg.value}(
            input,
            minReward,
            deadline,
            borrower,
            payable(address(this))
        );
    }
}
