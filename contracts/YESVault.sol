//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./YESToken.sol";
import "./interfaces/IYESVault.sol";
import "./interfaces/IYESController.sol";
import "./interfaces/ILending.sol";
import "./interfaces/IMarketImpl.sol";
import "./libraries/math/Exponential.sol";
import "./modules/kap20/interfaces/IKAP20.sol";
import "./modules/timelock/ReleaseTimelock.sol";
import "./modules/admin/Authorization.sol";
import "./modules/security//ReentrancyGuard.sol";
import "./modules/kyc/KYCHandler.sol";
import "./modules/committee/Committee.sol";
import "./modules/transferRouter/interfaces/INextTransferRouter.sol";
import "./abstracts/SuperAdmin.sol";
import "./abstracts/BKNextCallHelper.sol";

contract YESVault is
    IYESVault,
    ReleaseTimelock,
    Exponential,
    SuperAdmin,
    Committee,
    BKNextCallHelper
{
    string public constant override PROJECT = "bitkub-next-yuemmai";
    IYESController private _controller;
    YESToken private _yesToken;
    INextTransferRouter private _transferRouter;
    IMarketImpl private _marketImpl;

    address private _market;
    address private _admin;

    mapping(address => uint256) private _borrowLimitOf;
    mapping(address => uint256) private _tokensOf;
    mapping(address => uint256) private _releasedTo;

    uint256 private _totalAllocated;

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Restricted only admin");
        _;
    }

    constructor(
        address controller_,
        address yesToken_,
        address marketImpl_,
        address market_,
        uint256 releaseTime_,
        address admin_,
        address superAdmin_,
        address committee_,
        address callHelper_,
        address transferRouter_
    )
        ReleaseTimelock(releaseTime_)
        SuperAdmin(superAdmin_)
        BKNextCallHelper(callHelper_)
    {
        _setController(controller_);
        _setYESToken(yesToken_);
        _setMarketImpl(marketImpl_);
        _setTransferRouter(transferRouter_);
        _setMarket(market_);
        _setAdmin(admin_);

        committee = committee_;
    }

    /*** BK Next helpers ***/
    function requireKYC(address sender) internal view {
        IKYCBitkubChain kyc = _yesToken.kyc();
        require(
            kyc.kycsLevel(sender) >= _yesToken.acceptedKYCLevel(),
            "only Bitkub Next user"
        );
    }

    function airdrop(address beneficiary, uint256 amount)
        external
        override
        onlyAdmin
    {
        _tokensOf[beneficiary] += amount;
        _totalAllocated += amount;
        require(
            _totalAllocated <= _yesToken.balanceOf(address(this)),
            "Airdrop exceed supply"
        );
        emit Airdrop(beneficiary, amount);
    }

    function setBorrowLimit(address account, uint256 newAmount)
        external
        override
        onlyAdmin
    {
        uint256 oldAmount = _borrowLimitOf[account];
        _borrowLimitOf[account] = newAmount;
        (, uint256 collateralValue, uint256 borrowLimit, ) = _controller
            .getAccountLiquidity(account);
        require(
            borrowLimit >= collateralValue,
            "Borrow limit must be greater than collateral"
        );
        emit BorrowLimitUpdated(account, oldAmount, newAmount);
    }

    function deposit(uint256 amount, address sender) external override {
        if (msg.sender == callHelper) {
            requireKYC(sender);
            _transferRouter.transferFrom(
                PROJECT,
                address(_yesToken),
                sender,
                address(this),
                amount
            );
            _deposit(amount, sender);
        } else {
            _yesToken.transferFrom(msg.sender, address(this), amount);
            _deposit(amount, msg.sender);
        }
    }

    function _deposit(uint256 amount, address sender) private {
        _tokensOf[sender] += amount;
        _totalAllocated += amount;
        emit Deposit(sender, amount);
    }

    function withdraw(uint256 amount, address sender)
        external
        override
        onlyUnlocked
    {
        if (msg.sender == callHelper) {
            requireKYC(sender);
            _withdraw(amount, sender);
        } else {
            _withdraw(amount, msg.sender);
        }
    }

    function _withdraw(uint256 amount, address sender) private {
        (, uint256 collateralValue, , uint256 borrowValue) = _controller
            .getAccountLiquidity(sender);
        uint256 collateralFactorMantissa = _controller
            .collateralFactorMantissa();

        require(collateralValue >= borrowValue, "YESVault: ACCOUNT_SHORT_FALL");

        (MathError err, uint256 withdrawableTokens) = divScalarByExpTruncate(
            collateralValue - borrowValue,
            Exp({mantissa: collateralFactorMantissa})
        );

        require(err == MathError.NO_ERROR, "YESVault: MATH_ERROR");

        require(withdrawableTokens >= amount, "YESVault: NOT_ENOUGH_BALANCE");

        _tokensOf[sender] -= amount;
        _totalAllocated -= amount;

        _yesToken.transfer(sender, amount);

        emit Withdraw(sender, amount);
    }

    function sellMarket(
        address borrower,
        uint256 sellAmount,
        uint256 deadline
    ) external payable override returns (uint256) {
        uint256 err = _controller.seizeAllowed(msg.sender);
        require(err == 0, "YESVault: LIQUIDATE_SEIZE_CONTROLLER_REJECTION");

        address token = ILending(msg.sender).underlyingToken();

        uint256 borrowerTokens = _tokensOf[borrower];

        // If the borrower has lower tokens than sellAmount, sell all of his/her tokens
        uint256 amountIn = sellAmount >= borrowerTokens
            ? borrowerTokens
            : sellAmount;

        IKAP20(_yesToken).transfer(address(_marketImpl), amountIn);
        uint256 amountOut = IMarketImpl(_marketImpl).swapExactInput(
            _market,
            address(_yesToken),
            token,
            amountIn,
            0,
            msg.sender,
            deadline
        );

        _tokensOf[borrower] -= amountIn;
        _totalAllocated -= amountIn;

        return amountOut;
    }

    /*** Admin Functions ***/
    function setController(address newController)
        external
        override
        onlySuperAdmin
    {
        _setController(newController);
    }

    function _setController(address newController) private {
        IYESController oldController = _controller;
        _controller = IYESController(newController);
        require(_controller.isController(), "YESVault: INVALID_CONTROLLER");
        emit NewController(address(oldController), newController);
    }

    function _setYESToken(address newYESToken) private {
        YESToken oldYESToken = _yesToken;
        _yesToken = YESToken(newYESToken);
        emit NewYESToken(address(oldYESToken), newYESToken);
    }

    function setTransferRouter(address newTransferRouter) external override onlyCommittee {
       _setTransferRouter(newTransferRouter);
    }

    function _setTransferRouter(address newTransferRouter) private {
        _transferRouter = INextTransferRouter(newTransferRouter);
    }

    function setMarketImpl(address newImpl) external override onlySuperAdmin {
        _setMarketImpl(newImpl);
    }

    function _setMarketImpl(address newImpl) private {
        address oldImpl = address(_marketImpl);
        _marketImpl = IMarketImpl(newImpl);
        emit NewMarketImpl(oldImpl, newImpl);
    }

    function setMarket(address newMarket) external override onlySuperAdmin {
        _setMarket(newMarket);
    }

    function _setMarket(address newMarket) private {
        address oldMarket = _market;
        _market = newMarket;
        emit NewMarket(oldMarket, newMarket);
    }

    function setAdmin(address newAdmin) external override onlySuperAdmin {
        _setAdmin(newAdmin);
    }

    function _setAdmin(address newAdmin) private {
        address oldAdmin = _admin;
        _admin = newAdmin;
        emit NewAdmin(oldAdmin, newAdmin);
    }

    /*** Getters ***/

    function borrowLimitOf(address account)
        public
        view
        override
        returns (uint256)
    {
        return _borrowLimitOf[account];
    }

    function tokensOf(address account) public view override returns (uint256) {
        return _tokensOf[account];
    }

    function releasedTo(address account)
        public
        view
        override
        returns (uint256)
    {
        return _releasedTo[account];
    }

    function controller() public view override returns (address) {
        return address(_controller);
    }

    function yesToken() external view override returns (address) {
        return address(_yesToken);
    }

    function marketImpl() external view override returns (address) {
        return address(_marketImpl);
    }

    function market() external view override returns (address) {
        return _market;
    }

    function totalAllocated() external view override returns (uint256) {
        return _totalAllocated;
    }

    function admin() external view override returns (address) {
        return _admin;
    }

    function transferRouter() external view override returns (address) {
        return address(_transferRouter);
    }
}
