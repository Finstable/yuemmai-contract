//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "../interfaces/ILending.sol";
import "../interfaces/IYESController.sol";
import "../interfaces/IInterestRateModel.sol";
import "../libraries/error/ErrorReporter.sol";
import "../libraries/math/Exponential.sol";
import "../modules/kap20/interfaces/IKAP20.sol";
import "../modules/transferRouter/interfaces/INextTransferRouter.sol";
import "../modules/security/ReentrancyGuard.sol";
import "./SuperAdmin.sol";
import "./BKNextCallHelper.sol";
import "../LToken.sol";
import "../modules/committee/Committee.sol";

abstract contract LendingStorage is
    ILending,
    TokenErrorReporter,
    Exponential,
    ReentrancyGuard,
    SuperAdmin,
    BKNextCallHelper,
    Committee
{
    string public constant override PROJECT = "bitkub-next-yuemmai";
    bool public constant override isLContract = true;

    address public override underlyingToken;

    uint256 public override poolReserveFactorMantissa = 0.1e18; // 10%
    uint256 public override platformReserveFactorMantissa = 0.1e18; // 10%
    uint256 public override accrualBlockNumber;
    uint256 public override borrowIndex;
    uint256 public override totalBorrows;
    uint256 public override poolReserves;
    uint256 public override platformReserves;

    address payable public override beneficiary;
    address payable public override reservePool;

    uint256 public constant override protocolSeizeShareMantissa = 2.8e16; //2.8%

    uint256 internal initialExchangeRateMantissa;
    uint256 internal constant borrowRateMaxMantissa = 0.0005e16;
    uint256 internal constant reserveFactorMaxMantissa = 1e18;

    LToken internal _lToken;
    IYESController internal _controller;
    IInterestRateModel internal _interestRateModel;
    INextTransferRouter internal _transferRouter;

    struct ConstructorArgs {
        address underlyingToken;
        address controller;
        address interestRateModel;
        uint256 initialExchangeRateMantissa;
        address payable beneficiary;
        address payable poolReserve;
        string lTokenName;
        string lTokenSymbol;
        uint8 lTokenDecimals;
        address superAdmin;
        address callHelper;
        address committee;
        address adminRouter;
        address transferRouter;
        address kyc;
        uint256 acceptedKYCLevel;
    }

    struct BorrowSnapshot {
        uint256 principal;
        uint256 interestIndex;
    }

    mapping(address => BorrowSnapshot) internal accountBorrows;

    enum TransferMethod {
        METAMASK,
        BK_NEXT
    }
}
