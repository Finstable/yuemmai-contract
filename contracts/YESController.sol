//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./interfaces/IYESController.sol";
import "./interfaces/ILending.sol";
import "./interfaces/IYESVault.sol";
import "./interfaces/IYESPriceOracle.sol";
import "./libraries/error/ErrorReporter.sol";
import "./libraries/math/Exponential.sol";
import "./abstracts/SuperAdmin.sol";

contract YESController is
    IYESController,
    YESControllerErrorReporter,
    Exponential,
    SuperAdmin
{
    uint256 internal constant collateralFactorMaxMantissa = 0.9e18; // 90%

    bool public constant override isController = true;

    IYESVault private _yesVault;
    IYESPriceOracle private _oracle;
    ILending[] private _allMarkets;
    mapping(address => ILending[]) private _accountAssets;
    mapping(address => Market) private _markets;

    uint256 public override collateralFactorMantissa = 0.25e18; // 25%
    uint256 public override liquidationIncentiveMantissa = 1.08e18; //108%

    bool public override seizeGuardianPaused;
    mapping(address => bool) public override borrowGuardianPaused;
    mapping(address => bool) public override depositGuardianPaused;

    constructor(address superAdmin_)
        SuperAdmin(superAdmin_)
    {}

    /*** Assets You Are In ***/

    function getAssetsIn(address account)
        external
        view
        returns (ILending[] memory)
    {
        ILending[] memory assetsIn = _accountAssets[account];
        return assetsIn;
    }

    function checkMembership(address account, ILending lContract)
        external
        view
        returns (bool)
    {
        return _markets[address(lContract)].accountMembership[account];
    }

    function enterMarkets(address[] memory lContracts)
        external
        override
        returns (uint256[] memory)
    {
        uint256 len = lContracts.length;

        uint256[] memory results = new uint256[](len);
        for (uint256 i = 0; i < len; i++) {
            results[i] = uint256(
                addToMarketInternal(lContracts[i], msg.sender)
            );
        }

        return results;
    }

    function addToMarketInternal(address lContractAddress, address borrower)
        internal
        returns (Error)
    {
        Market storage marketToJoin = _markets[lContractAddress];

        if (!marketToJoin.isListed) {
            // market is not listed, cannot join
            return Error.MARKET_NOT_LISTED;
        }

        if (marketToJoin.accountMembership[borrower] == true) {
            // already joined
            return Error.NO_ERROR;
        }

        marketToJoin.accountMembership[borrower] = true;
        _accountAssets[borrower].push(ILending(lContractAddress));

        emit MarketEntered(lContractAddress, borrower);

        return Error.NO_ERROR;
    }

    function exitMarket(address lContractAddress)
        external
        override
        returns (uint256)
    {
        ILending lContract = ILending(lContractAddress);
        (uint256 oErr, , uint256 amountOwed, ) = lContract.getAccountSnapshot(
            msg.sender
        );
        require(oErr == 0, "exitMarket: getAccountSnapshot failed"); // semi-opaque error code

        /* Fail if the sender has a borrow balance */
        if (amountOwed != 0) {
            return
                fail(
                    Error.NONZERO_BORROW_BALANCE,
                    FailureInfo.EXIT_MARKET_BALANCE_OWED
                );
        }

        /* Fail if the sender is not permitted to withdraw all of their tokens */
        uint256 allowed = withdrawAllowedInternal(lContractAddress, msg.sender);
        if (allowed != 0) {
            return
                failOpaque(
                    Error.REJECTION,
                    FailureInfo.EXIT_MARKET_REJECTION,
                    allowed
                );
        }

        Market storage marketToExit = _markets[address(lContract)];

        /* Return true if the sender is not already ‘in’ the market */
        if (!marketToExit.accountMembership[msg.sender]) {
            return uint256(Error.NO_ERROR);
        }

        /* Set lContract account membership to false */
        delete marketToExit.accountMembership[msg.sender];

        /* Delete lContract from the account’s list of assets */
        // load into memory for faster iteration
        ILending[] memory userAssetList = _accountAssets[msg.sender];
        uint256 len = userAssetList.length;
        uint256 assetIndex = len;
        for (uint256 i = 0; i < len; i++) {
            if (userAssetList[i] == lContract) {
                assetIndex = i;
                break;
            }
        }

        // We *must* have found the asset in the list or our redundant data structure is broken
        assert(assetIndex < len);

        // copy last item in list to location of item to be removed, reduce length by 1
        ILending[] storage storedList = _accountAssets[msg.sender];
        storedList[assetIndex] = storedList[storedList.length - 1];
        storedList.pop();

        emit MarketExited(lContractAddress, msg.sender);

        return uint256(Error.NO_ERROR);
    }

    /*** Policy Hooks ***/

    function depositAllowed(address lContract)
        external
        view
        override
        returns (uint256)
    {
        if (!_markets[lContract].isListed) {
            return uint256(Error.MARKET_NOT_LISTED);
        }

        return uint256(Error.NO_ERROR);
    }

    function withdrawAllowed(address lContract, address withdrawer)
        external
        view
        override
        returns (uint256)
    {
        uint256 allowed = withdrawAllowedInternal(lContract, withdrawer);
        if (allowed != uint256(Error.NO_ERROR)) {
            return allowed;
        }

        return uint256(Error.NO_ERROR);
    }

    function withdrawAllowedInternal(address lContract, address withdrawer)
        internal
        view
        returns (uint256)
    {
        if (!_markets[lContract].isListed) {
            return uint256(Error.MARKET_NOT_LISTED);
        }

        /* If the withdrawer is not 'in' the market, then we can bypass the liquidity check */
        if (!_markets[lContract].accountMembership[withdrawer]) {
            return uint256(Error.NO_ERROR);
        }

        /* Otherwise, perform a hypothetical liquidity check to guard against shortfall */
        (
            Error err,
            uint256 collateralValue,
            ,
            uint256 borrowValue
        ) = getHypotheticalAccountLiquidityInternal(
                withdrawer,
                ILending(lContract),
                0
            );
        if (err != Error.NO_ERROR) {
            return uint256(err);
        }

        if (collateralValue < borrowValue) {
            return uint256(Error.INSUFFICIENT_LIQUIDITY);
        }

        return uint256(Error.NO_ERROR);

        // if (shortfall > 0) {
        //     return uint(Error.INSUFFICIENT_LIQUIDITY);
        // }

        // return uint(Error.NO_ERROR);
    }

    function borrowAllowed(
        address lContract,
        address borrower,
        uint256 borrowAmount
    ) external override returns (uint256) {
        // Pausing is a very serious situation - we revert to sound the alarms
        require(!borrowGuardianPaused[lContract], "borrow is paused");

        if (!_markets[lContract].isListed) {
            return uint256(Error.MARKET_NOT_LISTED);
        }

        if (!_markets[lContract].accountMembership[borrower]) {
            // only lContracts may call borrowAllowed if borrower not in market
            require(msg.sender == lContract, "sender must be lContract");

            // attempt to add borrower to the market
            Error err_ = addToMarketInternal(msg.sender, borrower);
            if (err_ != Error.NO_ERROR) {
                return uint256(err_);
            }

            // it should be impossible to break the important invariant
            assert(_markets[lContract].accountMembership[borrower]);
        }

        if (
            _oracle.getLatestPrice(ILending(lContract).underlyingToken()) == 0
        ) {
            return uint256(Error.PRICE_ERROR);
        }

        (
            Error err,
            uint256 collateralValue,
            uint256 borrowLimit,
            uint256 borrowValue
        ) = getHypotheticalAccountLiquidityInternal(
                borrower,
                ILending(lContract),
                borrowAmount
            );
        if (err != Error.NO_ERROR) {
            return uint256(err);
        }

        if (collateralValue < borrowLimit) {
            if (collateralValue < borrowValue) {
                return uint256(Error.INSUFFICIENT_LIQUIDITY);
            }
        } else {
            if (borrowLimit < borrowValue) {
                return uint256(Error.INSUFFICIENT_BORROW_LIMIT);
            }
        }

        return uint256(Error.NO_ERROR);
    }

    function repayBorrowAllowed(address lContract)
        external
        view
        override
        returns (uint256)
    {
        if (!_markets[lContract].isListed) {
            return uint256(Error.MARKET_NOT_LISTED);
        }

        return uint256(Error.NO_ERROR);
    }

    function liquidateBorrowAllowed(address lContract, address borrower)
        external
        view
        override
        returns (uint256)
    {
        if (!_markets[lContract].isListed) {
            return uint256(Error.MARKET_NOT_LISTED);
        }

        (
            Error err,
            uint256 collateralValue,
            uint256 borrowLimit,
            uint256 borrowBalance
        ) = getAccountLiquidityInternal(borrower);
        uint256 borrowPower = collateralValue <= borrowLimit
            ? collateralValue
            : borrowLimit;

        /* The borrower must have shortfall in order to be liquidatable */
        if (err != Error.NO_ERROR) {
            return uint256(err);
        }

        if (borrowPower >= borrowBalance) {
            return uint256(Error.INSUFFICIENT_SHORTFALL);
        }

        return uint256(Error.NO_ERROR);
    }

    function seizeAllowed(address lContract)
        external
        view
        override
        returns (uint256)
    {
        // Pausing is a very serious situation - we revert to sound the alarms
        require(!seizeGuardianPaused, "seize is paused");

        if (!_markets[lContract].isListed) {
            return uint256(Error.MARKET_NOT_LISTED);
        }

        if (address(ILending(lContract).controller()) != address(this)) {
            return uint256(Error.CONTROLLER_MISMATCH);
        }

        return uint256(Error.NO_ERROR);
    }

    /*** Liquidity/Liquidation Calculations ***/

    struct AccountLiquidityLocalVars {
        uint256 collateralValue;
        uint256 borrowLimit;
        uint256 sumBorrowPlusEffects;
        uint256 collateralBalance;
        uint256 borrowBalance;
        uint256 exchangeRateMantissa;
        uint256 oraclePriceMantissa;
        uint256 yesPrice;
        Exp collateralFactor;
        Exp exchangeRate;
        Exp oraclePrice;
        Exp tokensToDenom;
    }

    function getAccountLiquidity(address account)
        public
        view
        override
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (
            Error err,
            uint256 collateralValue,
            uint256 borrowLimit,
            uint256 borrowValue
        ) = getHypotheticalAccountLiquidityInternal(
                account,
                ILending(address(0)),
                0
            );

        return (uint256(err), collateralValue, borrowLimit, borrowValue);
    }

    function getAccountLiquidityInternal(address account)
        internal
        view
        returns (
            Error,
            uint256,
            uint256,
            uint256
        )
    {
        return
            getHypotheticalAccountLiquidityInternal(
                account,
                ILending(address(0)),
                0
            );
    }

    function getHypotheticalAccountLiquidity(
        address account,
        address lContractModify,
        uint256 borrowAmount
    )
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (
            Error err,
            uint256 collateralValue,
            uint256 borrowLimit,
            uint256 borrowValue
        ) = getHypotheticalAccountLiquidityInternal(
                account,
                ILending(lContractModify),
                borrowAmount
            );
        return (uint256(err), collateralValue, borrowLimit, borrowValue);
    }

    function getHypotheticalAccountLiquidityInternal(
        address account,
        ILending lContractModify,
        uint256 borrowAmount
    )
        internal
        view
        returns (
            Error,
            uint256,
            uint256,
            uint256
        )
    {
        AccountLiquidityLocalVars memory vars; // Holds all our calculation results
        uint256 oErr;

        vars.collateralBalance = _yesVault.tokensOf(account);

        vars.collateralFactor = Exp({mantissa: collateralFactorMantissa});

        // collateralValue = tokensToDenom * lContractBalance
        vars.collateralValue = mul_ScalarTruncate(
            vars.collateralFactor,
            vars.collateralBalance
        );

        vars.yesPrice = _oracle.getYESPrice();

        vars.borrowLimit = mul_ScalarTruncate(
            Exp({mantissa: vars.yesPrice}),
            borrowLimitOf(account)
        );

        // For each asset the account is in
        ILending[] memory assets = _accountAssets[account];

        for (uint256 i = 0; i < assets.length; i++) {
            ILending asset = assets[i];

            // Read the balances and exchange rate from the lContract
            (oErr, , vars.borrowBalance, ) = asset.getAccountSnapshot(account);

            if (oErr != 0) {
                // semi-opaque error code, we assume NO_ERROR == 0 is invariant between upgrades
                return (Error.SNAPSHOT_ERROR, 0, 0, 0);
            }

            // Get the normalized price of the asset
            vars.oraclePriceMantissa = _oracle.getLatestPrice(
                asset.underlyingToken()
            );
            if (vars.oraclePriceMantissa == 0) {
                return (Error.PRICE_ERROR, 0, 0, 0);
            }
            vars.oraclePrice = Exp({mantissa: vars.oraclePriceMantissa});

            // sumBorrowPlusEffects += oraclePrice * borrowBalance
            vars.sumBorrowPlusEffects = mul_ScalarTruncateAddUInt(
                vars.oraclePrice,
                vars.borrowBalance,
                vars.sumBorrowPlusEffects
            );

            // Calculate effects of interacting with lContractModify
            if (asset == lContractModify) {
                // borrow effect
                // sumBorrowPlusEffects += oraclePrice * borrowAmount
                vars.sumBorrowPlusEffects = mul_ScalarTruncateAddUInt(
                    vars.oraclePrice,
                    borrowAmount,
                    vars.sumBorrowPlusEffects
                );
            }
        }

        return (
            Error.NO_ERROR,
            vars.collateralValue,
            vars.borrowLimit,
            vars.sumBorrowPlusEffects
        );
    }

    function liquidateCalculateSeizeTokens(
        address lContract,
        uint256 borrowBalance
    ) external view override returns (uint256, uint256) {
        /* Read oracle prices for borrowed and collateral markets */
        uint256 priceBorrowedMantissa = _oracle.getLatestPrice(
            ILending(lContract).underlyingToken()
        );
        if (priceBorrowedMantissa == 0) {
            return (uint256(Error.PRICE_ERROR), 0);
        }

        uint256 seizeTokens;
        Exp memory incentivePrice;

        incentivePrice = mul_(
            Exp({mantissa: liquidationIncentiveMantissa}),
            Exp({mantissa: priceBorrowedMantissa})
        );

        seizeTokens = mul_ScalarTruncate(incentivePrice, borrowBalance);

        return (uint256(Error.NO_ERROR), seizeTokens);
    }

    /* Getters */

    function yesVault() external view override returns (address) {
        return address(_yesVault);
    }

    function oracle() external view override returns (address) {
        return address(_oracle);
    }

    function markets(address lContract, address account)
        external
        view
        override
        returns (bool, bool)
    {
        Market storage market = _markets[lContract];
        return (market.isListed, market.accountMembership[account]);
    }

    function allMarkets() external view override returns (address[] memory) {
        address[] memory marketList = new address[](_allMarkets.length);
        for (uint256 i = 0; i < _allMarkets.length; i++)
            marketList[i] = address(_allMarkets[i]);
        return marketList;
    }

    function accountAssets(address account)
        external
        view
        override
        returns (address[] memory)
    {
        ILending[] memory lContracts = _accountAssets[account];
        address[] memory assets = new address[](lContracts.length);
        for (uint256 i = 0; i < lContracts.length; i++)
            assets[i] = address(lContracts[i]);
        return assets;
    }

    function isDeprecated(ILending lContract) public view returns (bool) {
        return
            borrowGuardianPaused[address(lContract)] == true &&
            lContract.reserveFactorMantissa() == 1e18;
    }

    function borrowLimitOf(address account)
        public
        view
        override
        returns (uint256)
    {
        return _yesVault.borrowLimitOf(account);
    }

    function getBlockNumber() public view returns (uint256) {
        return block.number;
    }

    /* Admin Functions */

    function supportMarket(address lContractAddress)
        external
        onlySuperAdmin
        returns (uint256)
    {
        ILending lContract = ILending(lContractAddress);
        if (_markets[lContractAddress].isListed) {
            return
                fail(
                    Error.MARKET_ALREADY_LISTED,
                    FailureInfo.SUPPORT_MARKET_EXISTS
                );
        }

        lContract.isLContract(); // Sanity check to make sure its really a LToken

        _markets[lContractAddress].isListed = true;

        _addMarketInternal(lContractAddress);

        emit MarketListed(lContractAddress);

        return uint256(Error.NO_ERROR);
    }

    function _addMarketInternal(address lContract) internal {
        for (uint256 i = 0; i < _allMarkets.length; i++) {
            require(
                _allMarkets[i] != ILending(lContract),
                "market already added"
            );
        }
        _allMarkets.push(ILending(lContract));
    }

    function setSeizePaused(bool state)
        external
        override
        onlySuperAdmin
        returns (bool)
    {
        seizeGuardianPaused = state;
        emit ActionPaused("Seize", state);
        return state;
    }

    function setDepositPaused(address lContractAddress, bool state)
        external
        override
        onlySuperAdmin
        returns (bool)
    {
        require(
            _markets[lContractAddress].isListed,
            "cannot pause a market that is not listed"
        );

        depositGuardianPaused[lContractAddress] = state;
        emit LendingActionPaused(lContractAddress, "Deposit", state);
        return state;
    }

    function setBorrowPaused(address lContractAddress, bool state)
        external
        override
        onlySuperAdmin
        returns (bool)
    {
        require(
            _markets[lContractAddress].isListed,
            "cannot pause a market that is not listed"
        );

        borrowGuardianPaused[lContractAddress] = state;
        emit LendingActionPaused(lContractAddress, "Borrow", state);
        return state;
    }

    function setPriceOracle(address newOracle)
        external
        onlySuperAdmin
        returns (uint256)
    {
        // Track the old oracle for the controller
        IYESPriceOracle oldOracle = _oracle;

        // Set controller's oracle to newOracle
        _oracle = IYESPriceOracle(newOracle);

        // Emit NewPriceOracle(oldOracle, newOracle)
        emit NewPriceOracle(address(oldOracle), newOracle);

        return uint256(Error.NO_ERROR);
    }

    function setYESVault(address newYESVault)
        external
        onlySuperAdmin
        returns (uint256)
    {
        IYESVault oldYESVault = _yesVault;
        _yesVault = IYESVault(newYESVault);
        emit NewYESVault(address(oldYESVault), newYESVault);
        return uint256(Error.NO_ERROR);
    }

    function setCollateralFactor(uint256 newCollateralFactorMantissa)
        external
        onlySuperAdmin
        returns (uint256)
    {
        Exp memory newCollateralFactorExp = Exp({
            mantissa: newCollateralFactorMantissa
        });

        // Check collateral factor <= 1
        Exp memory highLimit = Exp({mantissa: collateralFactorMaxMantissa});
        if (lessThanExp(highLimit, newCollateralFactorExp)) {
            return
                fail(
                    Error.INVALID_COLLATERAL_FACTOR,
                    FailureInfo.SET_COLLATERAL_FACTOR_VALIDATION
                );
        }

        // Set market's collateral factor to new collateral factor, remember old value
        uint256 oldCollateralFactorMantissa = collateralFactorMantissa;
        collateralFactorMantissa = newCollateralFactorMantissa;

        // Emit event with asset, old collateral factor, and new collateral factor
        emit NewCollateralFactor(
            oldCollateralFactorMantissa,
            newCollateralFactorMantissa
        );

        return uint256(Error.NO_ERROR);
    }

    function setLiquidationIncentive(uint256 newLiquidationIncentiveMantissa)
        external
        onlySuperAdmin
        returns (uint256)
    {
        // Save current value for use in log
        uint256 oldLiquidationIncentiveMantissa = liquidationIncentiveMantissa;

        // Set liquidation incentive to new incentive
        liquidationIncentiveMantissa = newLiquidationIncentiveMantissa;

        // Emit event with old incentive, new incentive
        emit NewLiquidationIncentive(
            oldLiquidationIncentiveMantissa,
            newLiquidationIncentiveMantissa
        );

        return uint256(Error.NO_ERROR);
    }
}
