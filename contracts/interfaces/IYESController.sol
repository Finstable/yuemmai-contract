//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IYESController {
    struct Market {
        bool isListed;
        mapping(address => bool) accountMembership;
    }

    event MarketListed(address lToken);
    event MarketEntered(address lToken, address account);
    event MarketExited(address lToken, address account);
    event NewCollateralFactor(
        uint256 oldCollateralFactorMantissa,
        uint256 newCollateralFactorMantissa
    );
    event NewLiquidationIncentive(
        uint256 oldLiquidationIncentiveMantissa,
        uint256 newLiquidationIncentiveMantissa
    );
    event NewPriceOracle(address oldPriceOracle, address newPriceOracle);
    event NewYESVault(address oldYESVault, address newYESVault);
    event ActionPaused(string action, bool state);
    event LendingActionPaused(address lToken, string action, bool state);

    function isController() external returns (bool);

    function enterMarkets(address[] calldata lTokens)
        external
        returns (uint256[] memory);

    function exitMarket(address lToken) external returns (uint256);

    function depositAllowed(address lToken) external view returns (uint256);

    function withdrawAllowed(address lToken, address withdrawer)
        external
        view
        returns (uint256);

    function borrowAllowed(
        address lToken,
        address borrower,
        uint256 borrowAmount
    ) external returns (uint256);

    function liquidateBorrowAllowed(address lToken, address borrower)
        external
        view
        returns (uint256);

    function seizeAllowed(address lToken) external view returns (uint256);

    function repayBorrowAllowed(address lToken) external view returns (uint256);

    function getAccountLiquidity(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );

    function liquidateCalculateSeizeTokens(
        address lToken,
        uint256 borrowBalance
    ) external view returns (uint256, uint256);

    function yesVault() external view returns (address);

    function oracle() external view returns (address);

    function allMarkets() external view returns (address[] memory);

    function collateralFactorMantissa() external view returns (uint256);

    function liquidationIncentiveMantissa() external view returns (uint256);

    function markets(address lToken, address account)
        external
        view
        returns (bool, bool);

    function accountAssets(address account)
        external
        view
        returns (address[] memory);

    function depositGuardianPaused(address account)
        external
        view
        returns (bool);

    function borrowGuardianPaused(address account) external view returns (bool);

    function seizeGuardianPaused() external view returns (bool);

    function borrowLimitOf(address account) external view returns (uint256);

    function setBorrowPaused(address lContractAddress, bool state)
        external
        returns (bool);

    function setDepositPaused(address lContractAddress, bool state)
        external
        returns (bool);

    function setSeizePaused(bool state) external returns (bool);
}
