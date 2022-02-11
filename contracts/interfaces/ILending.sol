//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface ILending {
    /*** Market Events ***/

    event AccrueInterest(
        uint256 cashPrior,
        uint256 interestAccumulated,
        uint256 borrowIndex,
        uint256 totalBorrows
    );
    event Deposit(address user, uint256 depositAmount, uint256 mintTokens);
    event Withdraw(
        address user,
        uint256 withdrawAmount,
        uint256 withdrawTokens
    );
    event Borrow(
        address borrower,
        uint256 borrowAmount,
        uint256 accountBorrows,
        uint256 totalBorrows
    );
    event RepayBorrow(
        address payer,
        address borrower,
        uint256 repayAmount,
        uint256 accountBorrows,
        uint256 totalBorrows
    );
    event LiquidateBorrow(
        address liquidator,
        address borrower,
        uint256 repayAmount,
        uint256 seizeTokens
    );

    /*** Admin Events ***/

    event NewController(address oldController, address newController);
    event NewMarketInterestRateModel(
        address oldInterestRateModel,
        address newInterestRateModel
    );
    event NewPlatformReserveFactor(
        uint256 oldReserveFactorMantissa,
        uint256 newReserveFactorMantissa
    );
    event NewPoolReserveFactor(
        uint256 oldReserveFactorMantissa,
        uint256 newReserveFactorMantissa
    );
    event PlatformReservesClaimed(
        address beneficiary,
        uint256 reduceAmount,
        uint256 newTotalReserves
    );
    event PoolReservesClaimed(
        address reservePool,
        uint256 claimedAmount,
        uint256 poolReservesNew
    );
    event NewBeneficiary(
        address payable oldBeneficiary,
        address payable newBeneficiary
    );
    event NewReservePool(
        address payable oldReservePool,
        address payable newReservePool
    );
    event NewSlippageTolerrance(
        uint256 oldSlippageTolerrance,
        uint256 newSlippageTolerrance
    );

    // /*** User Interface ***/

    function isLContract() external returns (bool);

    function PROJECT() external returns (string memory);

    function balanceOfUnderlying(address owner) external returns (uint256);

    function getAccountSnapshot(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );

    function borrowRatePerBlock() external view returns (uint256);

    function supplyRatePerBlock() external view returns (uint256);

    function totalBorrowsCurrent() external returns (uint256);

    function borrowBalanceCurrent(address account) external returns (uint256);

    function borrowBalanceStored(address account)
        external
        view
        returns (uint256);

    function exchangeRateCurrent() external returns (uint256);

    function exchangeRateStored() external view returns (uint256);

    function getCash() external view returns (uint256);

    function accrueInterest() external returns (uint256);

    function lToken() external view returns (address);

    function underlyingToken() external view returns (address);

    function controller() external view returns (address);

    function interestRateModel() external view returns (address);

    function reserveFactorMantissa() external view returns (uint256);

    function poolReserveFactorMantissa() external view returns (uint256);

    function platformReserveFactorMantissa() external view returns (uint256);

    function accrualBlockNumber() external view returns (uint256);

    function borrowIndex() external view returns (uint256);

    function totalBorrows() external view returns (uint256);

    function platformReserves() external view returns (uint256);

    function poolReserves() external view returns (uint256);

    function totalReserves() external view returns (uint256);

    function protocolSeizeShareMantissa() external view returns (uint256);

    function beneficiary() external view returns (address payable);

    function reservePool() external view returns (address payable);

    /*** Admin Functions ***/

    function _setController(address newController) external returns (uint256);

    function _setPlatformReserveFactor(uint256 newReserveFactorMantissa)
        external
        returns (uint256);

    function _setPoolReserveFactor(uint256 newReserveFactorMantissa)
        external
        returns (uint256);

    function _setInterestRateModel(address newInterestRateModel)
        external
        returns (uint256);

    function _setBeneficiary(address payable newBeneficiary)
        external
        returns (uint256);

    function _setReservePool(address payable newReservePool)
        external
        returns (uint256);

    function pause() external returns (uint256);

    function unpause() external returns (uint256);

    /*** Protocol Functions ***/
    function _claimPoolReserves(uint256 claimedAmount)
        external
        returns (uint256);

    function _claimPlatformReserves(uint256 claimedAmount)
        external
        returns (uint256);
}
