//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./interfaces/ILendingLiquidate.sol";
import "./interfaces/ILKAP20Liquidate.sol";
import "./modules/kap20/interfaces/IKAP20.sol";
import "./modules/amm/interfaces/IUniswapRouter02.sol";
import "./modules/amm/interfaces/IUniswapV2Factory.sol";
import "./modules/amm/interfaces/IUniswapV2Pair.sol";

contract LiquidateV1 {
    address owner;
    address public KUBLending;
    address public SwapRouter;
    uint public errorCode;
    address public SwapFactory;

    constructor(
        address _KUBLending,
        address _SwapRouter,
        address _SwapFactory
    ) {
        owner = msg.sender;
        KUBLending = _KUBLending;
        SwapRouter = _SwapRouter;
        SwapFactory = _SwapFactory;
    }

    struct LiquidateInfo {
        ILKAP20Liquidate lending;
        uint256 amountADesired;
        uint amountAMin;
        address toSwap;
        uint256 amountBDesired;
        uint amountBMin;
        address finalToken;
        uint256 input;
        uint256 minReward;
        uint256 deadline;
        address borrower;
        address liquidator;
    }

    function KAP20liquidateBorrow(
        LiquidateInfo calldata args
    ) external returns (uint256) {
        uint256 err;

        // addliquidity to SwapRouter

        IKAP20(args.lending.underlyingToken()).transferFrom(
            args.liquidator,
            address(this),
            args.amountADesired
        );

        IKAP20(args.toSwap).transferFrom(
            args.liquidator,
            address(this),
            args.amountBDesired
        );

        IKAP20(args.lending.underlyingToken()).approve(
            SwapRouter,
            type(uint).max
        );

        IKAP20(args.toSwap).approve(SwapRouter, type(uint).max);

        IUniswapRouter02(SwapRouter).addLiquidity(
            args.lending.underlyingToken(),
            args.toSwap,
            args.amountADesired,
            args.amountBDesired,
            1,
            1,
            address(this),
            args.deadline
        );

        // // liquidator transfer input to this contract
        IKAP20 token = IKAP20(args.lending.underlyingToken());
        token.transferFrom(args.liquidator, address(this), args.input);

        // // this contract approve lending contract to spend input
        token.approve(address(args.lending), type(uint).max);

        // // swap input to yes token
        address[] memory _path = new address[](2);
        _path[0] = args.lending.underlyingToken();
        _path[1] = args.toSwap;

        // // this contract call lending contract to liquidate
        err = 0;
        if (address(args.lending) != KUBLending) {
            err = ILKAP20Liquidate(args.lending).liquidateBorrow(
                args.input,
                args.minReward,
                args.deadline,
                args.borrower,
                payable(address(this))
            );
            errorCode = err;
        } else {
            KKUBliquidate(
                args.input,
                args.minReward,
                args.deadline,
                args.borrower
            );
            errorCode = err;
        }

        require(err == 0, "liquidate borrow failed");
        // this contract swap to yes token and transfer to liquidator

        // //remove liquidirty from SwapRouter

        address pair = IUniswapV2Factory(SwapFactory).getPair(
            args.lending.underlyingToken(),
            args.toSwap
        );
        uint amountLiquidity = IUniswapV2Pair(pair).balanceOf(address(this));

        IUniswapV2Pair(pair).approve(SwapRouter, type(uint).max);

        IUniswapRouter02(SwapRouter).removeLiquidity(
            args.lending.underlyingToken(),
            args.toSwap,
            amountLiquidity,
            0,
            0,
            address(this),
            block.timestamp
        );

        _path[0] = args.toSwap;
        _path[1] = args.finalToken;
        // Yes Blance of this contract
        uint toSwapBalanceof;
        uint lendingBalanceof;
        uint LpBalanceof;

        toSwapBalanceof = IKAP20(args.toSwap).balanceOf(address(this));

        IKAP20(args.toSwap).approve(SwapRouter, toSwapBalanceof);

        IUniswapRouter02(SwapRouter).swapExactTokensForTokens(
            toSwapBalanceof,
            args.minReward,
            _path,
            args.liquidator,
            args.deadline
        );

        lendingBalanceof = IKAP20(args.lending.underlyingToken()).balanceOf(
            address(this)
        );
        LpBalanceof = IUniswapV2Pair(pair).balanceOf(address(this));
        toSwapBalanceof = IKAP20(args.toSwap).balanceOf(address(this));

        IKAP20(args.toSwap).transfer(args.liquidator, toSwapBalanceof);
        IKAP20(args.lending.underlyingToken()).transfer(
            args.liquidator,
            lendingBalanceof
        );
        IUniswapV2Pair(pair).transfer(args.liquidator, LpBalanceof);

        // require(
        //     IKAP20(lending.underlyingToken()).balanceOf(address(this)) >= input,
        //     "swap failed, not enough token"
        // );

        return errorCode;
    }

    function KKUBliquidate(
        uint256 input,
        uint256 minReward,
        uint256 deadline,
        address borrower
    ) internal {
        ILendingLiquidate(KUBLending).liquidateBorrow(
            input,
            minReward,
            deadline,
            borrower,
            payable(address(this))
        );
    }
}
