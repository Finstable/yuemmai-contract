//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "../LToken.sol";
import "./LendingSetter.sol";
import "../interfaces/IYESVault.sol";
import "../modules/kyc/KYCHandler.sol";
import "../modules/kyc/interfaces/IKYCBitkubChain.sol";
import "../modules/committee/Committee.sol";

abstract contract LendingContract is LendingSetter {
    constructor(ConstructorArgs memory args)
        SuperAdmin(args.superAdmin)
        BKNextCallHelper(args.callHelper)
    {
        require(args.initialExchangeRateMantissa > 0, "Invalid exchange rate");
        initialExchangeRateMantissa = args.initialExchangeRateMantissa;

        accrualBlockNumber = getBlockNumber();
        borrowIndex = mantissaOne;

        uint256 err1 = _setControllerFresh(args.controller);
        require(err1 == uint256(Error.NO_ERROR), "Controller failed");

        uint256 err2 = _setInterestRateModelFresh(args.interestRateModel);
        require(err2 == uint256(Error.NO_ERROR), "Interest model failed");

        uint256 err3 = _setBeneficiaryFresh(args.beneficiary);
        require(err3 == uint256(Error.NO_ERROR), "Beneficiary failed");

        uint256 err4 = _setReservePoolFresh(args.poolReserve);
        require(err4 == uint256(Error.NO_ERROR), "Reserve pool failed");

        _transferRouter = INextTransferRouter(args.transferRouter);

        underlyingToken = args.underlyingToken;
        committee = args.committee;
        IKAP20(underlyingToken).totalSupply();

        _lToken = new LToken(
            args.lTokenName,
            args.lTokenSymbol,
            args.lTokenDecimals,
            args.kyc,
            args.adminRouter,
            args.committee,
            args.transferRouter,
            args.acceptedKYCLevel
        );
    }

    function depositInternal(
        address user,
        uint256 depositAmount,
        TransferMethod method
    ) internal nonReentrant returns (uint256, uint256) {
        uint256 error = accrueInterest();
        if (error != uint256(Error.NO_ERROR)) {
            return (
                fail(Error(error), FailureInfo.DEPOSIT_ACCRUE_INTEREST_FAILED),
                0
            );
        }
        return depositFresh(user, depositAmount, method);
    }

    struct DepositLocalVars {
        Error err;
        MathError mathErr;
        uint256 exchangeRateMantissa;
        uint256 mintTokens;
        uint256 totalSupplyNew;
        uint256 accountTokensNew;
        uint256 actualDepositAmount;
    }

    function depositFresh(
        address user,
        uint256 depositAmount,
        TransferMethod method
    ) internal returns (uint256, uint256) {
        uint256 allowed = _controller.depositAllowed(address(this));
        if (allowed != 0) {
            return (
                failOpaque(
                    Error.CONTROLLER_REJECTION,
                    FailureInfo.DEPOSIT_CONTROLLER_REJECTION,
                    allowed
                ),
                0
            );
        }

        if (accrualBlockNumber != getBlockNumber()) {
            return (
                fail(
                    Error.MARKET_NOT_FRESH,
                    FailureInfo.DEPOSIT_FRESHNESS_CHECK
                ),
                0
            );
        }

        DepositLocalVars memory vars;

        (
            vars.mathErr,
            vars.exchangeRateMantissa
        ) = exchangeRateStoredInternal();
        if (vars.mathErr != MathError.NO_ERROR) {
            return (
                failOpaque(
                    Error.MATH_ERROR,
                    FailureInfo.DEPOSIT_EXCHANGE_RATE_READ_FAILED,
                    uint256(vars.mathErr)
                ),
                0
            );
        }

        vars.actualDepositAmount = doTransferIn(user, depositAmount, method);

        (vars.mathErr, vars.mintTokens) = divScalarByExpTruncate(
            vars.actualDepositAmount,
            Exp({mantissa: vars.exchangeRateMantissa})
        );
        require(
            vars.mathErr == MathError.NO_ERROR,
            "Exchange calculate failed"
        );

        _lToken.mint(user, vars.mintTokens);

        emit Deposit(user, vars.actualDepositAmount, vars.mintTokens);

        return (uint256(Error.NO_ERROR), vars.actualDepositAmount);
    }

    function withdrawInternal(
        address payable user,
        uint256 withdrawTokens,
        TransferMethod method
    ) internal nonReentrant returns (uint256) {
        uint256 error = accrueInterest();
        if (error != uint256(Error.NO_ERROR)) {
            return
                fail(Error(error), FailureInfo.WITHDRAW_ACCRUE_INTEREST_FAILED);
        }
        return withdrawFresh(user, withdrawTokens, 0, method);
    }

    function withdrawUnderlyingInternal(
        address payable user,
        uint256 withdrawAmount,
        TransferMethod method
    ) internal nonReentrant returns (uint256) {
        uint256 error = accrueInterest();
        if (error != uint256(Error.NO_ERROR)) {
            return
                fail(Error(error), FailureInfo.WITHDRAW_ACCRUE_INTEREST_FAILED);
        }
        return withdrawFresh(user, 0, withdrawAmount, method);
    }

    struct WithdrawLocalVars {
        Error err;
        MathError mathErr;
        uint256 exchangeRateMantissa;
        uint256 withdrawTokens;
        uint256 withdrawAmount;
        uint256 totalSupplyNew;
        uint256 accountTokensNew;
    }

    function withdrawFresh(
        address payable user,
        uint256 withdrawTokensIn,
        uint256 withdrawAmountIn,
        TransferMethod method
    ) internal returns (uint256) {
        require(
            withdrawTokensIn == 0 || withdrawAmountIn == 0,
            "Must have a zero input"
        );

        WithdrawLocalVars memory vars;

        (
            vars.mathErr,
            vars.exchangeRateMantissa
        ) = exchangeRateStoredInternal();
        if (vars.mathErr != MathError.NO_ERROR) {
            return
                failOpaque(
                    Error.MATH_ERROR,
                    FailureInfo.WITHDRAW_EXCHANGE_RATE_READ_FAILED,
                    uint256(vars.mathErr)
                );
        }

        if (withdrawTokensIn > 0) {
            vars.withdrawTokens = withdrawTokensIn;

            (vars.mathErr, vars.withdrawAmount) = mulScalarTruncate(
                Exp({mantissa: vars.exchangeRateMantissa}),
                withdrawTokensIn
            );
            if (vars.mathErr != MathError.NO_ERROR) {
                return
                    failOpaque(
                        Error.MATH_ERROR,
                        FailureInfo.WITHDRAW_EXCHANGE_TOKENS_CALCULATION_FAILED,
                        uint256(vars.mathErr)
                    );
            }
        } else {
            (vars.mathErr, vars.withdrawTokens) = divScalarByExpTruncate(
                withdrawAmountIn,
                Exp({mantissa: vars.exchangeRateMantissa})
            );
            if (vars.mathErr != MathError.NO_ERROR) {
                return
                    failOpaque(
                        Error.MATH_ERROR,
                        FailureInfo.WITHDRAW_EXCHANGE_AMOUNT_CALCULATION_FAILED,
                        uint256(vars.mathErr)
                    );
            }

            vars.withdrawAmount = withdrawAmountIn;
        }

        uint256 allowed = _controller.withdrawAllowed(address(this), user);
        if (allowed != 0) {
            return
                failOpaque(
                    Error.CONTROLLER_REJECTION,
                    FailureInfo.WITHDRAW_CONTROLLER_REJECTION,
                    allowed
                );
        }

        if (accrualBlockNumber != getBlockNumber()) {
            return
                fail(
                    Error.MARKET_NOT_FRESH,
                    FailureInfo.WITHDRAW_FRESHNESS_CHECK
                );
        }

        if (getCashPrior() < vars.withdrawAmount) {
            return
                fail(
                    Error.TOKEN_INSUFFICIENT_CASH,
                    FailureInfo.WITHDRAW_TRANSFER_OUT_NOT_POSSIBLE
                );
        }

        doTransferOut(user, vars.withdrawAmount, method);

        _lToken.burn(user, vars.withdrawTokens);

        emit Withdraw(user, vars.withdrawAmount, vars.withdrawTokens);

        return uint256(Error.NO_ERROR);
    }

    function borrowInternal(
        address payable borrower,
        uint256 borrowAmount,
        TransferMethod method
    ) internal nonReentrant returns (uint256) {
        uint256 error = accrueInterest();
        if (error != uint256(Error.NO_ERROR)) {
            return
                fail(Error(error), FailureInfo.BORROW_ACCRUE_INTEREST_FAILED);
        }
        return borrowFresh(borrower, borrowAmount, method);
    }

    struct BorrowLocalVars {
        MathError mathErr;
        uint256 accountBorrows;
        uint256 accountBorrowsNew;
        uint256 totalBorrowsNew;
    }

    function borrowFresh(
        address payable borrower,
        uint256 borrowAmount,
        TransferMethod method
    ) internal returns (uint256) {
        uint256 allowed = _controller.borrowAllowed(
            address(this),
            borrower,
            borrowAmount
        );
        if (allowed != 0) {
            return
                failOpaque(
                    Error.CONTROLLER_REJECTION,
                    FailureInfo.BORROW_CONTROLLER_REJECTION,
                    allowed
                );
        }

        if (accrualBlockNumber != getBlockNumber()) {
            return
                fail(
                    Error.MARKET_NOT_FRESH,
                    FailureInfo.BORROW_FRESHNESS_CHECK
                );
        }

        if (getCashPrior() < borrowAmount) {
            return
                fail(
                    Error.TOKEN_INSUFFICIENT_CASH,
                    FailureInfo.BORROW_CASH_NOT_AVAILABLE
                );
        }

        BorrowLocalVars memory vars;

        (vars.mathErr, vars.accountBorrows) = borrowBalanceStoredInternal(
            borrower
        );
        if (vars.mathErr != MathError.NO_ERROR) {
            return
                failOpaque(
                    Error.MATH_ERROR,
                    FailureInfo.BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
                    uint256(vars.mathErr)
                );
        }

        (vars.mathErr, vars.accountBorrowsNew) = addUInt(
            vars.accountBorrows,
            borrowAmount
        );
        if (vars.mathErr != MathError.NO_ERROR) {
            return
                failOpaque(
                    Error.MATH_ERROR,
                    FailureInfo
                        .BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED,
                    uint256(vars.mathErr)
                );
        }

        (vars.mathErr, vars.totalBorrowsNew) = addUInt(
            totalBorrows,
            borrowAmount
        );
        if (vars.mathErr != MathError.NO_ERROR) {
            return
                failOpaque(
                    Error.MATH_ERROR,
                    FailureInfo.BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
                    uint256(vars.mathErr)
                );
        }

        doTransferOut(borrower, borrowAmount, method);

        accountBorrows[borrower].principal = vars.accountBorrowsNew;
        accountBorrows[borrower].interestIndex = borrowIndex;
        totalBorrows = vars.totalBorrowsNew;

        emit Borrow(
            borrower,
            borrowAmount,
            vars.accountBorrowsNew,
            vars.totalBorrowsNew
        );

        return uint256(Error.NO_ERROR);
    }

    function repayBorrowInternal(
        address borrower,
        uint256 repayAmount,
        TransferMethod method
    ) internal nonReentrant returns (uint256, uint256) {
        uint256 error = accrueInterest();
        if (error != uint256(Error.NO_ERROR)) {
            return (
                fail(
                    Error(error),
                    FailureInfo.REPAY_BORROW_ACCRUE_INTEREST_FAILED
                ),
                0
            );
        }
        return repayBorrowFresh(borrower, borrower, repayAmount, method);
    }

    function repayBorrowBehalfInternal(
        address payer,
        address borrower,
        uint256 repayAmount,
        TransferMethod method
    ) internal nonReentrant returns (uint256, uint256) {
        uint256 error = accrueInterest();
        if (error != uint256(Error.NO_ERROR)) {
            return (
                fail(
                    Error(error),
                    FailureInfo.REPAY_BEHALF_ACCRUE_INTEREST_FAILED
                ),
                0
            );
        }
        return repayBorrowFresh(payer, borrower, repayAmount, method);
    }

    struct RepayBorrowLocalVars {
        Error err;
        MathError mathErr;
        uint256 repayAmount;
        uint256 borrowerIndex;
        uint256 accountBorrows;
        uint256 accountBorrowsNew;
        uint256 totalBorrowsNew;
        uint256 actualRepayAmount;
    }

    function repayBorrowFresh(
        address payer,
        address borrower,
        uint256 repayAmount,
        TransferMethod method
    ) internal returns (uint256, uint256) {
        uint256 allowed = _controller.repayBorrowAllowed(address(this));
        if (allowed != 0) {
            return (
                failOpaque(
                    Error.CONTROLLER_REJECTION,
                    FailureInfo.REPAY_BORROW_CONTROLLER_REJECTION,
                    allowed
                ),
                0
            );
        }

        if (accrualBlockNumber != getBlockNumber()) {
            return (
                fail(
                    Error.MARKET_NOT_FRESH,
                    FailureInfo.REPAY_BORROW_FRESHNESS_CHECK
                ),
                0
            );
        }

        RepayBorrowLocalVars memory vars;

        vars.borrowerIndex = accountBorrows[borrower].interestIndex;

        (vars.mathErr, vars.accountBorrows) = borrowBalanceStoredInternal(
            borrower
        );
        if (vars.mathErr != MathError.NO_ERROR) {
            return (
                failOpaque(
                    Error.MATH_ERROR,
                    FailureInfo
                        .REPAY_BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
                    uint256(vars.mathErr)
                ),
                0
            );
        }

        if (repayAmount == type(uint256).max) {
            vars.repayAmount = vars.accountBorrows;
        } else if (repayAmount > vars.accountBorrows) {
            vars.repayAmount = vars.accountBorrows;
        } else if (repayAmount > totalBorrows) {
            vars.repayAmount = totalBorrows;
        } else {
            vars.repayAmount = repayAmount;
        }

        if (payer != address(this)) {
            vars.actualRepayAmount = doTransferIn(
                payer,
                vars.repayAmount,
                method
            );
        } else {
            vars.actualRepayAmount = vars.repayAmount;
        }

        (vars.mathErr, vars.accountBorrowsNew) = subUInt(
            vars.accountBorrows,
            vars.actualRepayAmount
        );
        require(
            vars.mathErr == MathError.NO_ERROR,
            "Account borrow update failed"
        );

        (vars.mathErr, vars.totalBorrowsNew) = subUInt(
            totalBorrows,
            vars.actualRepayAmount
        );
        require(
            vars.mathErr == MathError.NO_ERROR,
            "Total borrow update failed"
        );

        accountBorrows[borrower].principal = vars.accountBorrowsNew;
        accountBorrows[borrower].interestIndex = borrowIndex;
        totalBorrows = vars.totalBorrowsNew;

        emit RepayBorrow(
            payer,
            borrower,
            vars.actualRepayAmount,
            vars.accountBorrowsNew,
            vars.totalBorrowsNew
        );

        return (uint256(Error.NO_ERROR), vars.actualRepayAmount);
    }

    function liquidateBorrowInternal(
        address payable liquidator,
        address borrower,
        uint256 input,
        uint256 minReward,
        uint256 deadline,
        TransferMethod method
    ) internal nonReentrant returns (uint256, uint256) {
        uint256 error = accrueInterest();
        if (error != uint256(Error.NO_ERROR)) {
            return (
                fail(
                    Error(error),
                    FailureInfo.LIQUIDATE_ACCRUE_BORROW_INTEREST_FAILED
                ),
                0
            );
        }

        return
            liquidateBorrowFresh(
                liquidator,
                borrower,
                input,
                minReward,
                deadline,
                method
            );
    }

    struct LiquidateBorrowLocalVars {
        MathError mErr;
        uint256 err;
        uint256 allowed;
        uint256 borrowBalance;
        uint256 seizeTokens;
        uint256 sellOutput;
        uint256 actualInput;
        uint256 actualRepayAmount;
        uint256 transferOutput;
        uint256 reward;
    }

    function liquidateBorrowFresh(
        address payable liquidator,
        address borrower,
        uint256 input,
        uint256 minReward,
        uint256 deadline,
        TransferMethod method
    ) internal returns (uint256, uint256) {
        LiquidateBorrowLocalVars memory vars;
        vars.allowed = _controller.liquidateBorrowAllowed(
            address(this),
            borrower
        );
        if (vars.allowed != 0) {
            return (
                failOpaque(
                    Error.CONTROLLER_REJECTION,
                    FailureInfo.LIQUIDATE_CONTROLLER_REJECTION,
                    vars.allowed
                ),
                0
            );
        }

        if (accrualBlockNumber != getBlockNumber()) {
            return (
                fail(
                    Error.MARKET_NOT_FRESH,
                    FailureInfo.LIQUIDATE_FRESHNESS_CHECK
                ),
                0
            );
        }

        if (borrower == liquidator) {
            return (
                fail(
                    Error.INVALID_ACCOUNT_PAIR,
                    FailureInfo.LIQUIDATE_LIQUIDATOR_IS_BORROWER
                ),
                0
            );
        }

        (vars.mErr, vars.borrowBalance) = borrowBalanceStoredInternal(borrower);

        if (vars.mErr != MathError.NO_ERROR) {
            return (
                fail(
                    Error.MATH_ERROR,
                    FailureInfo.LIQUIDATE_BORROW_BALANCE_ERROR
                ),
                0
            );
        }

        (vars.err, vars.seizeTokens) = _controller
            .liquidateCalculateSeizeTokens(address(this), vars.borrowBalance);

        require(
            vars.err == uint256(Error.NO_ERROR),
            "Calculate seize amount failed"
        );

        IYESVault yesVault = IYESVault(_controller.yesVault());
        vars.sellOutput = yesVault.sellMarket(
            borrower,
            vars.seizeTokens,
            deadline
        );
        vars.actualInput = doTransferIn(liquidator, input, method);

        (vars.err, vars.actualRepayAmount) = repayBorrowFresh(
            address(this),
            borrower,
            vars.borrowBalance,
            TransferMethod.METAMASK
        );

        if (vars.err != uint256(Error.NO_ERROR)) {
            return (
                fail(
                    Error(vars.err),
                    FailureInfo.LIQUIDATE_REPAY_BORROW_FRESH_FAILED
                ),
                0
            );
        }

        vars.transferOutput =
            (vars.sellOutput + vars.actualInput) -
            vars.actualRepayAmount;
        vars.reward = vars.transferOutput - vars.actualInput;
        require(vars.reward >= minReward, "Too low reward");

        doTransferOut(liquidator, vars.transferOutput, method);

        emit LiquidateBorrow(
            liquidator,
            borrower,
            vars.actualRepayAmount,
            vars.seizeTokens
        );

        return (uint256(Error.NO_ERROR), vars.actualRepayAmount);
    }

    /*** Fresh getters ***/

    function exchangeRateCurrent()
        public
        override
        nonReentrant
        returns (uint256)
    {
        require(
            accrueInterest() == uint256(Error.NO_ERROR),
            "Accrue interest failed"
        );
        return exchangeRateStored();
    }

    function borrowBalanceCurrent(address account)
        external
        override
        nonReentrant
        returns (uint256)
    {
        require(
            accrueInterest() == uint256(Error.NO_ERROR),
            "Accrue interest failed"
        );
        return borrowBalanceStored(account);
    }

    function totalBorrowsCurrent()
        external
        override
        nonReentrant
        returns (uint256)
    {
        require(
            accrueInterest() == uint256(Error.NO_ERROR),
            "Accrue interest failed"
        );
        return totalBorrows;
    }

    function balanceOfUnderlying(address owner)
        external
        override
        returns (uint256)
    {
        Exp memory exchangeRate = Exp({mantissa: exchangeRateCurrent()});
        (MathError mErr, uint256 balance) = mulScalarTruncate(
            exchangeRate,
            _lToken.balanceOf(owner)
        );
        require(mErr == MathError.NO_ERROR, "Math error");
        return balance;
    }

    /*** Protocol functions ***/

    function _claimPlatformReserves(uint256 claimedAmount)
        external
        override
        returns (uint256)
    {
        require(msg.sender == beneficiary, "Only beneficiary");
        uint256 platformReservesNew;

        if (beneficiary == address(0)) {
            return
                fail(
                    Error.INVALID_BENEFICIARY,
                    FailureInfo.CLAIM_PLATFORM_RESERVES_INVALID_BENEFICIARY
                );
        }

        if (getCashPrior() < claimedAmount) {
            return
                fail(
                    Error.TOKEN_INSUFFICIENT_CASH,
                    FailureInfo.CLAIM_PLATFORM_RESERVES_CASH_NOT_AVAILABLE
                );
        }

        if (claimedAmount > platformReserves) {
            return
                fail(
                    Error.BAD_INPUT,
                    FailureInfo.CLAIM_PLATFORM_RESERVES_VALIDATION
                );
        }

        platformReservesNew = platformReserves - claimedAmount;
        require(platformReservesNew <= platformReserves, "Overflow");

        platformReserves = platformReservesNew;

        doTransferOut(beneficiary, claimedAmount, TransferMethod.METAMASK);

        emit PlatformReservesClaimed(
            beneficiary,
            claimedAmount,
            platformReservesNew
        );

        return uint256(Error.NO_ERROR);
    }

    function _claimPoolReserves(uint256 claimedAmount)
        external
        override
        returns (uint256)
    {
        require(msg.sender == reservePool, "Only reserve pool");
        uint256 poolReservesNew;

        if (reservePool == address(0)) {
            return
                fail(
                    Error.INVALID_RESERVE_POOL,
                    FailureInfo.CLAIM_POOL_RESERVES_INVALID_RESERVE_POOL
                );
        }

        if (getCashPrior() < claimedAmount) {
            return
                fail(
                    Error.TOKEN_INSUFFICIENT_CASH,
                    FailureInfo.CLAIM_POOL_RESERVES_CASH_NOT_AVAILABLE
                );
        }

        if (claimedAmount > poolReserves) {
            return
                fail(
                    Error.BAD_INPUT,
                    FailureInfo.CLAIM_POOL_RESERVES_VALIDATION
                );
        }

        poolReservesNew = poolReserves - claimedAmount;
        require(poolReservesNew <= poolReserves, "Overflow");

        poolReserves = poolReservesNew;

        doTransferOut(reservePool, claimedAmount, TransferMethod.METAMASK);

        emit PoolReservesClaimed(reservePool, claimedAmount, poolReservesNew);

        return uint256(Error.NO_ERROR);
    }

    /*** BK Next helpers ***/
    function requireKYC(address sender) internal view {
        IKYCBitkubChain kyc = _lToken.kyc();
        require(
            kyc.kycsLevel(sender) >= _lToken.acceptedKYCLevel(),
            "only Bitkub Next user"
        );
    }

    /*** Token functions ***/
    function doTransferIn(
        address from,
        uint256 amount,
        TransferMethod method
    ) internal virtual returns (uint256);

    function doTransferOut(
        address payable to,
        uint256 amount,
        TransferMethod method
    ) internal virtual;
}
