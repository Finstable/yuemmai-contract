//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./LendingInterest.sol";

abstract contract LendingSetter is LendingInterest {
    function _setController(address newController)
        public
        override
        onlySuperAdmin
        returns (uint256)
    {
        uint256 error = accrueInterest();
        if (error != uint256(Error.NO_ERROR)) {
            return
                fail(
                    Error(error),
                    FailureInfo.SET_CONTROLLER_RATE_MODEL_ACCRUE_INTEREST_FAILED
                );
        }

        return _setControllerFresh(newController);
    }

    function _setControllerFresh(address newController)
        internal
        returns (uint256)
    {
        IYESController oldController = _controller;

        if (accrualBlockNumber != getBlockNumber()) {
            return
                fail(
                    Error.MARKET_NOT_FRESH,
                    FailureInfo.SET_INTEREST_RATE_MODEL_FRESH_CHECK
                );
        }

        _controller = IYESController(newController);

        require(_controller.isController(), "Controller error");

        emit NewController(address(oldController), newController);

        return uint256(Error.NO_ERROR);
    }

    function _setInterestRateModel(address newInterestRateModel)
        public
        override
        onlySuperAdmin
        returns (uint256)
    {
        uint256 error = accrueInterest();
        if (error != uint256(Error.NO_ERROR)) {
            return
                fail(
                    Error(error),
                    FailureInfo.SET_INTEREST_RATE_MODEL_ACCRUE_INTEREST_FAILED
                );
        }
        return _setInterestRateModelFresh(newInterestRateModel);
    }

    function _setInterestRateModelFresh(address newInterestRateModel)
        internal
        returns (uint256)
    {
        IInterestRateModel oldInterestRateModel;

        if (accrualBlockNumber != getBlockNumber()) {
            return
                fail(
                    Error.MARKET_NOT_FRESH,
                    FailureInfo.SET_INTEREST_RATE_MODEL_FRESH_CHECK
                );
        }

        oldInterestRateModel = _interestRateModel;
        _interestRateModel = IInterestRateModel(newInterestRateModel);

        require(
            _interestRateModel.isInterestRateModel(),
            "Interest model error"
        );

        emit NewMarketInterestRateModel(
            address(oldInterestRateModel),
            newInterestRateModel
        );

        return uint256(Error.NO_ERROR);
    }

    function _setPlatformReserveFactor(uint256 newPlatformReserveFactorMantissa)
        external
        override
        nonReentrant
        onlySuperAdmin
        returns (uint256)
    {
        uint256 error = accrueInterest();
        if (error != uint256(Error.NO_ERROR)) {
            return
                fail(
                    Error(error),
                    FailureInfo
                        .SET_PLATFORM_RESERVE_FACTOR_ACCRUE_INTEREST_FAILED
                );
        }
        return _setPlatformReserveFactorFresh(newPlatformReserveFactorMantissa);
    }

    function _setPlatformReserveFactorFresh(
        uint256 newPlatformReserveFactorMantissa
    ) internal returns (uint256) {
        if (accrualBlockNumber != getBlockNumber()) {
            return
                fail(
                    Error.MARKET_NOT_FRESH,
                    FailureInfo.SET_PLATFORM_RESERVE_FACTOR_FRESH_CHECK
                );
        }

        uint256 newTotalReserveFactorMantissa = newPlatformReserveFactorMantissa +
                poolReserveFactorMantissa;

        if (newTotalReserveFactorMantissa > reserveFactorMaxMantissa) {
            return
                fail(
                    Error.BAD_INPUT,
                    FailureInfo.SET_PLATFORM_RESERVE_FACTOR_BOUNDS_CHECK
                );
        }

        uint256 oldPlatformReserveFactorMantissa = platformReserveFactorMantissa;
        platformReserveFactorMantissa = newPlatformReserveFactorMantissa;

        emit NewPlatformReserveFactor(
            oldPlatformReserveFactorMantissa,
            newPlatformReserveFactorMantissa
        );

        return uint256(Error.NO_ERROR);
    }

    function _setPoolReserveFactor(uint256 newPoolReserveFactorMantissa)
        external
        override
        nonReentrant
        onlySuperAdmin
        returns (uint256)
    {
        uint256 error = accrueInterest();
        if (error != uint256(Error.NO_ERROR)) {
            return
                fail(
                    Error(error),
                    FailureInfo.SET_POOL_RESERVE_FACTOR_ACCRUE_INTEREST_FAILED
                );
        }
        return _setPoolReserveFactorFresh(newPoolReserveFactorMantissa);
    }

    function _setPoolReserveFactorFresh(uint256 newPoolReserveFactorMantissa)
        internal
        returns (uint256)
    {
        if (accrualBlockNumber != getBlockNumber()) {
            return
                fail(
                    Error.MARKET_NOT_FRESH,
                    FailureInfo.SET_POOL_RESERVE_FACTOR_FRESH_CHECK
                );
        }

        uint256 newTotalReserveFactorMantissa = platformReserveFactorMantissa +
            newPoolReserveFactorMantissa;
        if (newTotalReserveFactorMantissa > reserveFactorMaxMantissa) {
            return
                fail(
                    Error.BAD_INPUT,
                    FailureInfo.SET_POOL_RESERVE_FACTOR_BOUNDS_CHECK
                );
        }

        uint256 oldPoolReserveFactorMantissa = poolReserveFactorMantissa;
        poolReserveFactorMantissa = newPoolReserveFactorMantissa;

        emit NewPoolReserveFactor(
            oldPoolReserveFactorMantissa,
            newPoolReserveFactorMantissa
        );

        return uint256(Error.NO_ERROR);
    }

    function _setBeneficiary(address payable newBeneficiary)
        external
        override
        nonReentrant
        returns (uint256)
    {
        require(msg.sender == beneficiary, "Only beneficiary");
        uint256 error = accrueInterest();
        if (error != uint256(Error.NO_ERROR)) {
            return
                fail(
                    Error(error),
                    FailureInfo.SET_BENEFICIARY_ACCRUE_INTEREST_FAILED
                );
        }
        return _setBeneficiaryFresh(newBeneficiary);
    }

    function _setBeneficiaryFresh(address payable newBeneficiary)
        internal
        returns (uint256)
    {
        if (accrualBlockNumber != getBlockNumber()) {
            return
                fail(
                    Error.MARKET_NOT_FRESH,
                    FailureInfo.SET_BENEFICIARY_FRESH_CHECK
                );
        }

        address payable oldBeneficiary = beneficiary;
        beneficiary = newBeneficiary;

        emit NewBeneficiary(oldBeneficiary, newBeneficiary);

        return uint256(Error.NO_ERROR);
    }

    function _setReservePool(address payable newReservePool)
        external
        override
        nonReentrant
        returns (uint256)
    {
        require(msg.sender == reservePool, "Only reserve pool");
        uint256 error = accrueInterest();
        if (error != uint256(Error.NO_ERROR)) {
            return
                fail(
                    Error(error),
                    FailureInfo.SET_RESERVE_POOL_ACCRUE_INTEREST_FAILED
                );
        }
        return _setReservePoolFresh(newReservePool);
    }

    function setTransferRouter(address newTransferRouter)
        external
        override
        onlyCommittee
        returns (uint256)
    {
        _transferRouter = INextTransferRouter(newTransferRouter);
        return uint256(Error.NO_ERROR);
    }

    function _setReservePoolFresh(address payable newReservePool)
        internal
        returns (uint256)
    {
        if (accrualBlockNumber != getBlockNumber()) {
            return
                fail(
                    Error.MARKET_NOT_FRESH,
                    FailureInfo.SET_RESERVE_POOL_FRESH_CHECK
                );
        }

        address payable oldReservePool = reservePool;
        reservePool = newReservePool;

        emit NewReservePool(oldReservePool, newReservePool);

        return uint256(Error.NO_ERROR);
    }

    function pause() external override onlySuperAdmin returns (uint256) {
        uint256 error = accrueInterest();
        if (error != uint256(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.PAUSE_ACCRUE_INTEREST_FAILED);
        }
        _lToken.pause();
        return uint256(Error.NO_ERROR);
    }

    function unpause() external override onlySuperAdmin returns (uint256) {
        uint256 error = accrueInterest();
        if (error != uint256(Error.NO_ERROR)) {
            return
                fail(Error(error), FailureInfo.UNPAUSE_ACCRUE_INTEREST_FAILED);
        }
        _lToken.unpause();
        return uint256(Error.NO_ERROR);
    }
}
