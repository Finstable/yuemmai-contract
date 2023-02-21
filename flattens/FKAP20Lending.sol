// Sources flattened with hardhat v2.8.4 https://hardhat.org

// File contracts/modules/kap20/interfaces/IKToken.sol

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

interface IKToken {
    function internalTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function externalTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

// File contracts/modules/erc20/interfaces/IEIP20NonStandard.sol

pragma solidity >=0.5.0;

/**
 * @title EIP20NonStandardInterface
 * @dev Version of ERC20 with no return values for `transfer` and `transferFrom`
 *  See https://medium.com/coinmonks/missing-return-value-bug-at-least-130-tokens-affected-d67bf08521ca
 */
interface IEIP20NonStandard {
    /**
     * @notice Get the total number of tokens in circulation
     * @return The supply of tokens
     */
    function totalSupply() external view returns (uint256);

    /**
     * @notice Gets the balance of the specified address
     * @param owner The address from which the balance will be retrieved
     * @return balance The balance
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    ///
    /// !!!!!!!!!!!!!!
    /// !!! NOTICE !!! `transfer` does not return a value, in violation of the ERC-20 specification
    /// !!!!!!!!!!!!!!
    ///

    /**
     * @notice Transfer `amount` tokens from `msg.sender` to `dst`
     * @param dst The address of the destination account
     * @param amount The number of tokens to transfer
     */
    function transfer(address dst, uint256 amount) external;

    ///
    /// !!!!!!!!!!!!!!
    /// !!! NOTICE !!! `transferFrom` does not return a value, in violation of the ERC-20 specification
    /// !!!!!!!!!!!!!!
    ///

    /**
     * @notice Transfer `amount` tokens from `src` to `dst`
     * @param src The address of the source account
     * @param dst The address of the destination account
     * @param amount The number of tokens to transfer
     */
    function transferFrom(address src, address dst, uint256 amount) external;

    /**
     * @notice Approve `spender` to transfer up to `amount` from `src`
     * @dev This will overwrite the approval amount for `spender`
     *  and is subject to issues noted [here](https://eips.ethereum.org/EIPS/eip-20#approve)
     * @param spender The address of the account which may transfer tokens
     * @param amount The number of tokens that are approved
     * @return success Whether or not the approval succeeded
     */
    function approve(
        address spender,
        uint256 amount
    ) external returns (bool success);

    /**
     * @notice Get the current allowance from `owner` for `spender`
     * @param owner The address of the account which owns the tokens to be spent
     * @param spender The address of the account which may transfer tokens
     * @return remaining The number of tokens allowed to be spent
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
}

// File contracts/interfaces/IInterestRateModel.sol

pragma solidity >=0.5.0;

/**
 * @title Compound's InterestRateModel Interface
 * @author Compound
 */
interface IInterestRateModel {
    /// @notice Indicator that this is an InterestRateModel contract (for inspection)
    function isInterestRateModel() external view returns (bool);

    /**
     * @notice Calculates the current borrow interest rate per block
     * @param cash The total amount of cash the market has
     * @param borrows The total amount of borrows the market has outstanding
     * @param reserves The total amount of reserves the market has
     * @return The borrow rate per block (as a percentage, and scaled by 1e18)
     */
    function getBorrowRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves
    ) external view returns (uint256);

    // /**
    //   * @notice Calculates the current supply interest rate per block
    //   * @param cash The total amount of cash the market has
    //   * @param borrows The total amount of borrows the market has outstanding
    //   * @param reserves The total amount of reserves the market has
    //   * @param reserveFactorMantissa The current reserve factor the market has
    //   * @return The supply rate per block (as a percentage, and scaled by 1e18)
    //   */
    function getSupplyRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves,
        uint256 reserveFactorMantissa
    ) external view returns (uint256);
}

// File contracts/modules/kap20/interfaces/IKAP20.sol

pragma solidity >=0.6.0 <0.9.0;

interface IKAP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function adminApprove(
        address owner,
        address spender,
        uint256 amount
    ) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function adminTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File contracts/modules/kyc/interfaces/IKYCBitkubChain.sol

pragma solidity >=0.6.0 <0.9.0;

interface IKYCBitkubChain {
    function kycsLevel(address _addr) external view returns (uint256);
}

// File contracts/modules/kyc/interfaces/IKAP20KYC.sol

pragma solidity >=0.5.0;

interface IKAP20KYC {
    event ActivateOnlyKYCAddress();
    event SetKYC(address oldKyc, address newKyc);
    event SetAccecptedKycLevel(uint256 oldKycLevel, uint256 newKycLevel);

    function activateOnlyKycAddress() external;

    function setKYC(address _kyc) external;

    function setAcceptedKycLevel(uint256 _kycLevel) external;

    function kyc() external returns (IKYCBitkubChain);

    function acceptedKYCLevel() external returns (uint256);

    function isActivatedOnlyKycAddress() external returns (bool);
}

// File contracts/interfaces/ILToken.sol

pragma solidity >=0.5.0;

interface ILToken is IKAP20, IKToken, IKAP20KYC {
    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;
}

// File contracts/interfaces/ILKAP20.sol

pragma solidity >=0.5.0;

interface ILKAP20 is ILToken {
    function mint(uint256 mintAmount) external returns (uint256);

    function withdraw(uint256 withdrawTokens) external returns (uint256);

    function withdrawUnderlying(
        uint256 withdrawAmount
    ) external returns (uint256);

    function borrow(uint256 borrowAmount) external returns (uint256);

    function repayBorrow(uint256 repayAmount) external returns (uint256);
}

// File contracts/modules/misc/Context.sol

pragma solidity 0.8.11;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File contracts/modules/pause/Pausable.sol

pragma solidity 0.8.11;

abstract contract Pausable {
    event Paused(address account);
    event Unpaused(address account);

    bool public paused;

    constructor() {
        paused = false;
    }

    modifier whenNotPaused() {
        require(!paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused, "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        paused = true;
        emit Paused(msg.sender);
    }

    function _unpause() internal virtual whenPaused {
        paused = false;
        emit Unpaused(msg.sender);
    }
}

// File contracts/modules/admin/interfaces/IAdminProjectRouter.sol

pragma solidity >=0.6.0 <0.9.0;

interface IAdminProjectRouter {
    function isSuperAdmin(
        address _addr,
        string calldata _project
    ) external view returns (bool);

    function isAdmin(
        address _addr,
        string calldata _project
    ) external view returns (bool);
}

// File contracts/modules/admin/Authorization.sol

pragma solidity 0.8.11;

abstract contract Authorization {
    IAdminProjectRouter public adminProjectRouter;
    string public PROJECT;

    event AdminProjectRouterSet(
        address indexed oldAdmin,
        address indexed newAdmin,
        address indexed caller
    );

    modifier onlySuperAdmin() {
        require(
            adminProjectRouter.isSuperAdmin(msg.sender, PROJECT),
            "Authorization: restricted only super admin"
        );
        _;
    }

    modifier onlyAdmin() {
        require(
            adminProjectRouter.isAdmin(msg.sender, PROJECT),
            "Authorization: restricted only admin"
        );
        _;
    }

    modifier onlySuperAdminOrAdmin() {
        require(
            adminProjectRouter.isSuperAdmin(msg.sender, PROJECT) ||
                adminProjectRouter.isAdmin(msg.sender, PROJECT),
            "Authorization: restricted only super admin or admin"
        );
        _;
    }

    function setAdminProjectRouter(
        address _adminProjectRouter
    ) public virtual onlySuperAdmin {
        require(
            _adminProjectRouter != address(0),
            "Authorization: new admin project router is the zero address"
        );
        emit AdminProjectRouterSet(
            address(adminProjectRouter),
            _adminProjectRouter,
            msg.sender
        );
        adminProjectRouter = IAdminProjectRouter(_adminProjectRouter);
    }
}

// File contracts/modules/kyc/KYCHandler.sol

pragma solidity 0.8.11;

abstract contract KYCHandler {
    IKYCBitkubChain public kyc;

    uint256 public acceptedKYCLevel;
    bool public isActivatedOnlyKYCAddress;

    function _activateOnlyKYCAddress() internal virtual {
        isActivatedOnlyKYCAddress = true;
    }

    function _setKYC(address _kyc) internal virtual {
        kyc = IKYCBitkubChain(_kyc);
    }

    function _setAcceptedKYCLevel(uint256 _kycLevel) internal virtual {
        acceptedKYCLevel = _kycLevel;
    }
}

// File contracts/modules/access/Ownable.sol

// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

pragma solidity 0.8.11;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File contracts/modules/committee/Committee.sol

pragma solidity 0.8.11;

abstract contract Committee {
    address public committee;

    event CommitteeSet(
        address indexed oldCommittee,
        address indexed newCommittee,
        address indexed caller
    );

    modifier onlyCommittee() {
        require(
            msg.sender == committee,
            "Committee: restricted only committee"
        );
        _;
    }

    function setCommittee(address _committee) public virtual onlyCommittee {
        emit CommitteeSet(committee, _committee, msg.sender);
        committee = _committee;
    }
}

// File contracts/modules/access/AccessController.sol

pragma solidity 0.8.11;

abstract contract AccessController is
    Authorization,
    KYCHandler,
    Ownable,
    Committee
{
    event TransferRouterSet(
        address indexed oldTransferRouter,
        address indexed newTransferRouter,
        address indexed caller
    );

    address public transferRouter;

    modifier onlyOwnerOrCommittee() {
        require(
            msg.sender == owner() || msg.sender == committee,
            "AccessController: restricted only owner or committee"
        );
        _;
    }

    modifier onlySuperAdminOrTransferRouter() {
        require(
            adminProjectRouter.isSuperAdmin(msg.sender, PROJECT) ||
                msg.sender == transferRouter,
            "AccessController: restricted only super admin or transfer router"
        );
        _;
    }

    modifier onlySuperAdminOrCommittee() {
        require(
            adminProjectRouter.isSuperAdmin(msg.sender, PROJECT) ||
                msg.sender == committee,
            "AccessController: restricted only super admin or committee"
        );
        _;
    }

    modifier onlySuperAdminOrOwner() {
        require(
            adminProjectRouter.isSuperAdmin(msg.sender, PROJECT) ||
                msg.sender == owner(),
            "AccessController: restricted only super admin or owner"
        );
        _;
    }

    function activateOnlyKYCAddress() external onlyCommittee {
        _activateOnlyKYCAddress();
    }

    function setKYC(address _kyc) external onlyCommittee {
        _setKYC(_kyc);
    }

    function setAcceptedKYCLevel(uint256 _kycLevel) external onlyCommittee {
        _setAcceptedKYCLevel(_kycLevel);
    }

    function setTransferRouter(
        address _transferRouter
    ) external onlyOwnerOrCommittee {
        emit TransferRouterSet(transferRouter, _transferRouter, msg.sender);
        transferRouter = _transferRouter;
    }

    function setAdminProjectRouter(
        address _adminProjectRouter
    ) public override onlyOwnerOrCommittee {
        require(
            _adminProjectRouter != address(0),
            "Authorization: new admin project router is the zero address"
        );
        emit AdminProjectRouterSet(
            address(adminProjectRouter),
            _adminProjectRouter,
            msg.sender
        );
        adminProjectRouter = IAdminProjectRouter(_adminProjectRouter);
    }
}

// File contracts/modules/kap20/KAP20.sol

pragma solidity 0.8.11;

contract KAP20 is IKAP20, IKToken, Pausable, AccessController {
    mapping(address => uint256) _balances;

    mapping(address => mapping(address => uint256)) internal _allowances;

    uint256 public override totalSupply;

    string public override name;
    string public override symbol;
    uint8 public override decimals;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _projectName,
        uint8 _decimals,
        address _kyc,
        address _adminProjectRouter,
        address _committee,
        address _transferRouter,
        uint256 _acceptedKYCLevel
    ) {
        name = _name;
        symbol = _symbol;
        PROJECT = _projectName;
        decimals = _decimals;
        kyc = IKYCBitkubChain(_kyc);
        adminProjectRouter = IAdminProjectRouter(_adminProjectRouter);
        committee = _committee;
        transferRouter = _transferRouter;
        acceptedKYCLevel = _acceptedKYCLevel;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override whenNotPaused returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function adminApprove(
        address owner,
        address spender,
        uint256 amount
    )
        public
        virtual
        override
        whenNotPaused
        onlySuperAdminOrAdmin
        returns (bool)
    {
        require(
            kyc.kycsLevel(owner) >= acceptedKYCLevel &&
                kyc.kycsLevel(spender) >= acceptedKYCLevel,
            "KAP20: owner or spender address is not a KYC user"
        );

        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override whenNotPaused returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(
            currentAllowance >= amount,
            "KAP20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(
            currentAllowance >= subtractedValue,
            "KAP20: decreased allowance below zero"
        );
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "KAP20: transfer from the zero address");
        require(recipient != address(0), "KAP20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "KAP20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "KAP20: mint to the zero address");

        totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "KAP20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "KAP20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "KAP20: approve from the zero address");
        require(spender != address(0), "KAP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function adminTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override onlyCommittee returns (bool) {
        if (isActivatedOnlyKYCAddress) {
            require(
                kyc.kycsLevel(sender) > 0 && kyc.kycsLevel(recipient) > 0,
                "KAP721: only internal purpose"
            );
        }
        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "KAP20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        return true;
    }

    function internalTransfer(
        address sender,
        address recipient,
        uint256 amount
    )
        external
        override
        whenNotPaused
        onlySuperAdminOrTransferRouter
        returns (bool)
    {
        require(
            kyc.kycsLevel(sender) >= acceptedKYCLevel &&
                kyc.kycsLevel(recipient) >= acceptedKYCLevel,
            "KAP20: only internal purpose"
        );

        _transfer(sender, recipient, amount);
        return true;
    }

    function externalTransfer(
        address sender,
        address recipient,
        uint256 amount
    )
        external
        override
        whenNotPaused
        onlySuperAdminOrTransferRouter
        returns (bool)
    {
        require(
            kyc.kycsLevel(sender) >= acceptedKYCLevel,
            "KAP20: only internal purpose"
        );

        _transfer(sender, recipient, amount);
        return true;
    }
}

// File contracts/LToken.sol

pragma solidity 0.8.11;

contract LToken is KAP20 {
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _kyc,
        address _adminProjectRouter,
        address _committee,
        address _transferRouter,
        uint256 _acceptedKYCLevel
    )
        KAP20(
            _name,
            _symbol,
            "bitkub-next-yuemmai",
            _decimals,
            _kyc,
            _adminProjectRouter,
            _committee,
            _transferRouter,
            _acceptedKYCLevel
        )
    {}

    function mint(address _to, uint256 _amount) external onlyOwner {
        _mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) external onlyOwner {
        _burn(_from, _amount);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}

// File contracts/interfaces/ILending.sol

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

    function getAccountSnapshot(
        address account
    ) external view returns (uint256, uint256, uint256, uint256);

    function borrowRatePerBlock() external view returns (uint256);

    function supplyRatePerBlock() external view returns (uint256);

    function totalBorrowsCurrent() external returns (uint256);

    function borrowBalanceCurrent(address account) external returns (uint256);

    function borrowBalanceStored(
        address account
    ) external view returns (uint256);

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

    function transferRouter() external view returns (address);

    /*** Admin Functions ***/

    function _setController(address newController) external returns (uint256);

    function _setPlatformReserveFactor(
        uint256 newReserveFactorMantissa
    ) external returns (uint256);

    function _setPoolReserveFactor(
        uint256 newReserveFactorMantissa
    ) external returns (uint256);

    function _setInterestRateModel(
        address newInterestRateModel
    ) external returns (uint256);

    function _setBeneficiary(
        address payable newBeneficiary
    ) external returns (uint256);

    function _setReservePool(
        address payable newReservePool
    ) external returns (uint256);

    function setTransferRouter(
        address newTransferRouter
    ) external returns (uint256);

    function pause() external returns (uint256);

    function unpause() external returns (uint256);

    /*** Protocol Functions ***/
    function _claimPoolReserves(
        uint256 claimedAmount
    ) external returns (uint256);

    function _claimPlatformReserves(
        uint256 claimedAmount
    ) external returns (uint256);
}

// File contracts/interfaces/IYESController.sol

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

    function enterMarkets(
        address[] calldata lTokens
    ) external returns (uint256[] memory);

    function exitMarket(address lToken) external returns (uint256);

    function depositAllowed(address lToken) external view returns (uint256);

    function withdrawAllowed(
        address lToken,
        address withdrawer
    ) external view returns (uint256);

    function borrowAllowed(
        address lToken,
        address borrower,
        uint256 borrowAmount
    ) external returns (uint256);

    function liquidateBorrowAllowed(
        address lToken,
        address borrower
    ) external view returns (uint256);

    function seizeAllowed(address lToken) external view returns (uint256);

    function repayBorrowAllowed(address lToken) external view returns (uint256);

    function getAccountLiquidity(
        address account
    ) external view returns (uint256, uint256, uint256, uint256);

    function liquidateCalculateSeizeTokens(
        address lToken,
        uint256 borrowBalance
    ) external view returns (uint256, uint256);

    function yesVault() external view returns (address);

    function oracle() external view returns (address);

    function allMarkets() external view returns (address[] memory);

    function collateralFactorMantissa() external view returns (uint256);

    function liquidationIncentiveMantissa() external view returns (uint256);

    function markets(
        address lToken,
        address account
    ) external view returns (bool, bool);

    function accountAssets(
        address account
    ) external view returns (address[] memory);

    function depositGuardianPaused(
        address account
    ) external view returns (bool);

    function borrowGuardianPaused(address account) external view returns (bool);

    function seizeGuardianPaused() external view returns (bool);

    function borrowLimitOf(address account) external view returns (uint256);

    function setBorrowPaused(
        address lContractAddress,
        bool state
    ) external returns (bool);

    function setDepositPaused(
        address lContractAddress,
        bool state
    ) external returns (bool);

    function setSeizePaused(bool state) external returns (bool);
}

// File contracts/libraries/error/ErrorReporter.sol

pragma solidity >=0.5.0;

contract YESControllerErrorReporter {
    enum Error {
        NO_ERROR,
        UNAUTHORIZED,
        CONTROLLER_MISMATCH,
        INSUFFICIENT_SHORTFALL,
        INSUFFICIENT_LIQUIDITY,
        INSUFFICIENT_BORROW_LIMIT,
        INVALID_CLOSE_FACTOR,
        INVALID_COLLATERAL_FACTOR,
        INVALID_LIQUIDATION_INCENTIVE,
        MARKET_NOT_ENTERED, // no longer possible
        MARKET_NOT_LISTED,
        MARKET_ALREADY_LISTED,
        MATH_ERROR,
        NONZERO_BORROW_BALANCE,
        PRICE_ERROR,
        REJECTION,
        SNAPSHOT_ERROR,
        TOO_MANY_ASSETS,
        TOO_MUCH_REPAY
    }

    enum FailureInfo {
        ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
        ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK,
        EXIT_MARKET_BALANCE_OWED,
        EXIT_MARKET_REJECTION,
        SET_CLOSE_FACTOR_OWNER_CHECK,
        SET_CLOSE_FACTOR_VALIDATION,
        SET_COLLATERAL_FACTOR_OWNER_CHECK,
        SET_COLLATERAL_FACTOR_NO_EXISTS,
        SET_COLLATERAL_FACTOR_VALIDATION,
        SET_COLLATERAL_FACTOR_WITHOUT_PRICE,
        SET_IMPLEMENTATION_OWNER_CHECK,
        SET_LIQUIDATION_INCENTIVE_OWNER_CHECK,
        SET_LIQUIDATION_INCENTIVE_VALIDATION,
        SET_MAX_ASSETS_OWNER_CHECK,
        SET_PENDING_ADMIN_OWNER_CHECK,
        SET_PENDING_IMPLEMENTATION_OWNER_CHECK,
        SET_PRICE_ORACLE_OWNER_CHECK,
        SUPPORT_MARKET_EXISTS,
        SUPPORT_MARKET_OWNER_CHECK,
        SET_PAUSE_GUARDIAN_OWNER_CHECK,
        SET_BYES_TOKEN_CHECK
    }

    /**
     * @dev `error` corresponds to enum Error; `info` corresponds to enum FailureInfo, and `detail` is an arbitrary
     * contract-specific code that enables us to report opaque error codes from upgradeable contracts.
     **/
    event Failure(uint256 error, uint256 info, uint256 detail);

    /**
     * @dev use this when reporting a known error from the money market or a non-upgradeable collaborator
     */
    function fail(Error err, FailureInfo info) internal returns (uint256) {
        emit Failure(uint256(err), uint256(info), 0);

        return uint256(err);
    }

    /**
     * @dev use this when reporting an opaque error from an upgradeable collaborator contract
     */
    function failOpaque(
        Error err,
        FailureInfo info,
        uint256 opaqueError
    ) internal returns (uint256) {
        emit Failure(uint256(err), uint256(info), opaqueError);

        return uint256(err);
    }
}

contract TokenErrorReporter {
    enum Error {
        NO_ERROR,
        UNAUTHORIZED,
        BAD_INPUT,
        CONTROLLER_REJECTION,
        CONTROLLER_CALCULATION_ERROR,
        INTEREST_RATE_MODEL_ERROR,
        INVALID_ACCOUNT_PAIR,
        INVALID_CLOSE_AMOUNT_REQUESTED,
        INVALID_COLLATERAL_FACTOR,
        MATH_ERROR,
        MARKET_NOT_FRESH,
        MARKET_NOT_LISTED,
        TOKEN_INSUFFICIENT_ALLOWANCE,
        TOKEN_INSUFFICIENT_BALANCE,
        TOKEN_INSUFFICIENT_CASH,
        TOKEN_TRANSFER_IN_FAILED,
        TOKEN_TRANSFER_OUT_FAILED,
        INVALID_BENEFICIARY,
        INVALID_RESERVE_POOL,
        INVALID_MARKET,
        INVALID_MARKET_IMPL,
        INVALID_VAULT,
        INVALID_YES_TOKEN
    }

    enum FailureInfo {
        ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
        ACCRUE_INTEREST_ACCUMULATED_INTEREST_CALCULATION_FAILED,
        ACCRUE_INTEREST_BORROW_RATE_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_BORROW_INDEX_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_TOTAL_BORROWS_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_PLATFORM_RESERVES_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_POOL_RESERVES_CALCULATION_FAILED,
        ACCRUE_INTEREST_SIMPLE_INTEREST_FACTOR_CALCULATION_FAILED,
        BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        BORROW_ACCRUE_INTEREST_FAILED,
        BORROW_CASH_NOT_AVAILABLE,
        BORROW_FRESHNESS_CHECK,
        BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED,
        BORROW_MARKET_NOT_LISTED,
        BORROW_CONTROLLER_REJECTION,
        LIQUIDATE_ACCRUE_BORROW_INTEREST_FAILED,
        LIQUIDATE_ACCRUE_COLLATERAL_INTEREST_FAILED,
        LIQUIDATE_COLLATERAL_FRESHNESS_CHECK,
        LIQUIDATE_CONTROLLER_REJECTION,
        LIQUIDATE_CONTROLLER_CALCULATE_AMOUNT_SEIZE_FAILED,
        LIQUIDATE_CLOSE_AMOUNT_IS_UINT_MAX,
        LIQUIDATE_CLOSE_AMOUNT_IS_ZERO,
        LIQUIDATE_FRESHNESS_CHECK,
        LIQUIDATE_LIQUIDATOR_IS_BORROWER,
        LIQUIDATE_REPAY_BORROW_FRESH_FAILED,
        LIQUIDATE_SEIZE_BALANCE_INCREMENT_FAILED,
        LIQUIDATE_SEIZE_BALANCE_DECREMENT_FAILED,
        LIQUIDATE_SEIZE_CONTROLLER_REJECTION,
        LIQUIDATE_SEIZE_LIQUIDATOR_IS_BORROWER,
        LIQUIDATE_SEIZE_TOO_MUCH,
        DEPOSIT_ACCRUE_INTEREST_FAILED,
        DEPOSIT_CONTROLLER_REJECTION,
        DEPOSIT_EXCHANGE_CALCULATION_FAILED,
        DEPOSIT_EXCHANGE_RATE_READ_FAILED,
        DEPOSIT_FRESHNESS_CHECK,
        DEPOSIT_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED,
        DEPOSIT_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
        DEPOSIT_TRANSFER_IN_FAILED,
        DEPOSIT_TRANSFER_IN_NOT_POSSIBLE,
        WITHDRAW_ACCRUE_INTEREST_FAILED,
        WITHDRAW_CONTROLLER_REJECTION,
        WITHDRAW_EXCHANGE_TOKENS_CALCULATION_FAILED,
        WITHDRAW_EXCHANGE_AMOUNT_CALCULATION_FAILED,
        WITHDRAW_EXCHANGE_RATE_READ_FAILED,
        WITHDRAW_FRESHNESS_CHECK,
        WITHDRAW_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED,
        WITHDRAW_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
        WITHDRAW_TRANSFER_OUT_NOT_POSSIBLE,
        CLAIM_PLATFORM_RESERVES_ACCRUE_INTEREST_FAILED,
        CLAIM_POOL_RESERVES_CASH_NOT_AVAILABLE,
        REDUCE_POOL_RESERVES_ACCRUE_INTEREST_FAILED,
        CLAIM_PLATFORM_RESERVES_ADMIN_CHECK,
        REDUCE_POOL_RESERVES_ADMIN_CHECK,
        CLAIM_PLATFORM_RESERVES_CASH_NOT_AVAILABLE,
        REDUCE_POOL_RESERVES_CASH_NOT_AVAILABLE,
        CLAIM_PLATFORM_RESERVES_FRESH_CHECK,
        REDUCE_POOL_RESERVES_FRESH_CHECK,
        CLAIM_PLATFORM_RESERVES_VALIDATION,
        REDUCE_POOL_RESERVES_VALIDATION,
        REPAY_BEHALF_ACCRUE_INTEREST_FAILED,
        REPAY_BORROW_ACCRUE_INTEREST_FAILED,
        REPAY_BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_CONTROLLER_REJECTION,
        REPAY_BORROW_FRESHNESS_CHECK,
        REPAY_BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_TRANSFER_IN_NOT_POSSIBLE,
        SET_COLLATERAL_FACTOR_OWNER_CHECK,
        SET_COLLATERAL_FACTOR_VALIDATION,
        SET_CONTROLLER_OWNER_CHECK,
        SET_CONTROLLER_RATE_MODEL_ACCRUE_INTEREST_FAILED,
        SET_INTEREST_RATE_MODEL_ACCRUE_INTEREST_FAILED,
        SET_INTEREST_RATE_MODEL_FRESH_CHECK,
        SET_INTEREST_RATE_MODEL_OWNER_CHECK,
        SET_MAX_ASSETS_OWNER_CHECK,
        SET_ORACLE_MARKET_NOT_LISTED,
        SET_PENDING_ADMIN_OWNER_CHECK,
        SET_PLATFORM_RESERVE_FACTOR_ACCRUE_INTEREST_FAILED,
        SET_POOL_RESERVE_FACTOR_ACCRUE_INTEREST_FAILED,
        SET_RESERVE_FACTOR_ADMIN_CHECK,
        SET_PLATFORM_RESERVE_FACTOR_FRESH_CHECK,
        SET_POOL_RESERVE_FACTOR_FRESH_CHECK,
        SET_PLATFORM_RESERVE_FACTOR_BOUNDS_CHECK,
        SET_POOL_RESERVE_FACTOR_BOUNDS_CHECK,
        TRANSFER_CONTROLLER_REJECTION,
        TRANSFER_NOT_ALLOWED,
        TRANSFER_NOT_ENOUGH,
        TRANSFER_TOO_MUCH,
        ADD_PLATFORM_RESERVES_ACCRUE_INTEREST_FAILED,
        ADD_POOL_RESERVES_ACCRUE_INTEREST_FAILED,
        ADD_PLATFORM_RESERVES_FRESH_CHECK,
        ADD_POOL_RESERVES_FRESH_CHECK,
        ADD_PLATFORM_RESERVES_TRANSFER_IN_NOT_POSSIBLE,
        ADD_POOL_RESERVES_TRANSFER_IN_NOT_POSSIBLE,
        CLAIM_PLATFORM_RESERVES_INVALID_BENEFICIARY,
        CLAIM_POOL_RESERVES_INVALID_RESERVE_POOL,
        CLAIM_POOL_RESERVES_VALIDATION,
        SET_BENEFICIARY_ACCRUE_INTEREST_FAILED,
        SET_BENEFICIARY_FRESH_CHECK,
        SET_RESERVE_POOL_ACCRUE_INTEREST_FAILED,
        SET_RESERVE_POOL_FRESH_CHECK,
        SET_SLIPPAGE_TOLERRANCE_ACCRUE_INTEREST_FAILED,
        SET_SLIPPAGE_TOLERRANCE_FRESH_CHECK,
        LIQUIDATE_BORROW_BALANCE_ERROR,
        PAUSE_ACCRUE_INTEREST_FAILED,
        UNPAUSE_ACCRUE_INTEREST_FAILED
    }

    /**
     * @dev `error` corresponds to enum Error; `info` corresponds to enum FailureInfo, and `detail` is an arbitrary
     * contract-specific code that enables us to report opaque error codes from upgradeable contracts.
     **/
    event Failure(uint256 error, uint256 info, uint256 detail);

    /**
     * @dev use this when reporting a known error from the money market or a non-upgradeable collaborator
     */
    function fail(Error err, FailureInfo info) internal returns (uint256) {
        emit Failure(uint256(err), uint256(info), 0);

        return uint256(err);
    }

    /**
     * @dev use this when reporting an opaque error from an upgradeable collaborator contract
     */
    function failOpaque(
        Error err,
        FailureInfo info,
        uint256 opaqueError
    ) internal returns (uint256) {
        emit Failure(uint256(err), uint256(info), opaqueError);

        return uint256(err);
    }
}

// File contracts/libraries/math/CarefulMath.sol

pragma solidity >=0.5.0;

/**
 * @title Careful Math
 * @author Compound
 * @notice Derived from OpenZeppelin's SafeMath library
 *         https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol
 */
contract CarefulMath {
    /**
     * @dev Possible error codes that we can return
     */
    enum MathError {
        NO_ERROR,
        DIVISION_BY_ZERO,
        INTEGER_OVERFLOW,
        INTEGER_UNDERFLOW
    }

    /**
     * @dev Multiplies two numbers, returns an error on overflow.
     */
    function mulUInt(
        uint256 a,
        uint256 b
    ) internal pure returns (MathError, uint256) {
        if (a == 0) {
            return (MathError.NO_ERROR, 0);
        }

        uint256 c = a * b;

        if (c / a != b) {
            return (MathError.INTEGER_OVERFLOW, 0);
        } else {
            return (MathError.NO_ERROR, c);
        }
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function divUInt(
        uint256 a,
        uint256 b
    ) internal pure returns (MathError, uint256) {
        if (b == 0) {
            return (MathError.DIVISION_BY_ZERO, 0);
        }

        return (MathError.NO_ERROR, a / b);
    }

    /**
     * @dev Subtracts two numbers, returns an error on overflow (i.e. if subtrahend is greater than minuend).
     */
    function subUInt(
        uint256 a,
        uint256 b
    ) internal pure returns (MathError, uint256) {
        if (b <= a) {
            return (MathError.NO_ERROR, a - b);
        } else {
            return (MathError.INTEGER_UNDERFLOW, 0);
        }
    }

    /**
     * @dev Adds two numbers, returns an error on overflow.
     */
    function addUInt(
        uint256 a,
        uint256 b
    ) internal pure returns (MathError, uint256) {
        uint256 c = a + b;

        if (c >= a) {
            return (MathError.NO_ERROR, c);
        } else {
            return (MathError.INTEGER_OVERFLOW, 0);
        }
    }

    /**
     * @dev add a and b and then subtract c
     */
    function addThenSubUInt(
        uint256 a,
        uint256 b,
        uint256 c
    ) internal pure returns (MathError, uint256) {
        (MathError err0, uint256 sum) = addUInt(a, b);

        if (err0 != MathError.NO_ERROR) {
            return (err0, 0);
        }

        return subUInt(sum, c);
    }
}

// File contracts/libraries/math/ExponentialNoError.sol

pragma solidity >=0.5.0;

/**
 * @title Exponential module for storing fixed-precision decimals
 * @author Compound
 * @notice Exp is a struct which stores decimals with a fixed precision of 18 decimal places.
 *         Thus, if we wanted to store the 5.1, mantissa would store 5.1e18. That is:
 *         `Exp({mantissa: 5100000000000000000})`.
 */
contract ExponentialNoError {
    uint256 constant expScale = 1e18;
    uint256 constant doubleScale = 1e36;
    uint256 constant halfExpScale = expScale / 2;
    uint256 constant mantissaOne = expScale;

    struct Exp {
        uint256 mantissa;
    }

    struct Double {
        uint256 mantissa;
    }

    /**
     * @dev Truncates the given exp to a whole number value.
     *      For example, truncate(Exp{mantissa: 15 * expScale}) = 15
     */
    function truncate(Exp memory exp) internal pure returns (uint256) {
        // Note: We are not using careful math here as we're performing a division that cannot fail
        return exp.mantissa / expScale;
    }

    /**
     * @dev Multiply an Exp by a scalar, then truncate to return an unsigned integer.
     */
    function mul_ScalarTruncate(
        Exp memory a,
        uint256 scalar
    ) internal pure returns (uint256) {
        Exp memory product = mul_(a, scalar);
        return truncate(product);
    }

    /**
     * @dev Multiply an Exp by a scalar, truncate, then add an to an unsigned integer, returning an unsigned integer.
     */
    function mul_ScalarTruncateAddUInt(
        Exp memory a,
        uint256 scalar,
        uint256 addend
    ) internal pure returns (uint256) {
        Exp memory product = mul_(a, scalar);
        return add_(truncate(product), addend);
    }

    /**
     * @dev Checks if first Exp is less than second Exp.
     */
    function lessThanExp(
        Exp memory left,
        Exp memory right
    ) internal pure returns (bool) {
        return left.mantissa < right.mantissa;
    }

    /**
     * @dev Checks if left Exp <= right Exp.
     */
    function lessThanOrEqualExp(
        Exp memory left,
        Exp memory right
    ) internal pure returns (bool) {
        return left.mantissa <= right.mantissa;
    }

    /**
     * @dev Checks if left Exp > right Exp.
     */
    function greaterThanExp(
        Exp memory left,
        Exp memory right
    ) internal pure returns (bool) {
        return left.mantissa > right.mantissa;
    }

    /**
     * @dev returns true if Exp is exactly zero
     */
    function isZeroExp(Exp memory value) internal pure returns (bool) {
        return value.mantissa == 0;
    }

    function safe224(
        uint256 n,
        string memory errorMessage
    ) internal pure returns (uint224) {
        require(n < 2 ** 224, errorMessage);
        return uint224(n);
    }

    function safe32(
        uint256 n,
        string memory errorMessage
    ) internal pure returns (uint32) {
        require(n < 2 ** 32, errorMessage);
        return uint32(n);
    }

    function add_(
        Exp memory a,
        Exp memory b
    ) internal pure returns (Exp memory) {
        return Exp({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(
        Double memory a,
        Double memory b
    ) internal pure returns (Double memory) {
        return Double({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(uint256 a, uint256 b) internal pure returns (uint256) {
        return add_(a, b, "addition overflow");
    }

    function add_(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub_(
        Exp memory a,
        Exp memory b
    ) internal pure returns (Exp memory) {
        return Exp({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(
        Double memory a,
        Double memory b
    ) internal pure returns (Double memory) {
        return Double({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub_(a, b, "subtraction underflow");
    }

    function sub_(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function mul_(
        Exp memory a,
        Exp memory b
    ) internal pure returns (Exp memory) {
        return Exp({mantissa: mul_(a.mantissa, b.mantissa) / expScale});
    }

    function mul_(Exp memory a, uint256 b) internal pure returns (Exp memory) {
        return Exp({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint256 a, Exp memory b) internal pure returns (uint256) {
        return mul_(a, b.mantissa) / expScale;
    }

    function mul_(
        Double memory a,
        Double memory b
    ) internal pure returns (Double memory) {
        return Double({mantissa: mul_(a.mantissa, b.mantissa) / doubleScale});
    }

    function mul_(
        Double memory a,
        uint256 b
    ) internal pure returns (Double memory) {
        return Double({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint256 a, Double memory b) internal pure returns (uint256) {
        return mul_(a, b.mantissa) / doubleScale;
    }

    function mul_(uint256 a, uint256 b) internal pure returns (uint256) {
        return mul_(a, b, "multiplication overflow");
    }

    function mul_(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, errorMessage);
        return c;
    }

    function div_(
        Exp memory a,
        Exp memory b
    ) internal pure returns (Exp memory) {
        return Exp({mantissa: div_(mul_(a.mantissa, expScale), b.mantissa)});
    }

    function div_(Exp memory a, uint256 b) internal pure returns (Exp memory) {
        return Exp({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint256 a, Exp memory b) internal pure returns (uint256) {
        return div_(mul_(a, expScale), b.mantissa);
    }

    function div_(
        Double memory a,
        Double memory b
    ) internal pure returns (Double memory) {
        return
            Double({mantissa: div_(mul_(a.mantissa, doubleScale), b.mantissa)});
    }

    function div_(
        Double memory a,
        uint256 b
    ) internal pure returns (Double memory) {
        return Double({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint256 a, Double memory b) internal pure returns (uint256) {
        return div_(mul_(a, doubleScale), b.mantissa);
    }

    function div_(uint256 a, uint256 b) internal pure returns (uint256) {
        return div_(a, b, "divide by zero");
    }

    function div_(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function fraction(
        uint256 a,
        uint256 b
    ) internal pure returns (Double memory) {
        return Double({mantissa: div_(mul_(a, doubleScale), b)});
    }
}

// File contracts/libraries/math/Exponential.sol

pragma solidity >=0.5.0;

/**
 * @title Exponential module for storing fixed-precision decimals
 * @author Compound
 * @dev Legacy contract for compatibility reasons with existing contracts that still use MathError
 * @notice Exp is a struct which stores decimals with a fixed precision of 18 decimal places.
 *         Thus, if we wanted to store the 5.1, mantissa would store 5.1e18. That is:
 *         `Exp({mantissa: 5100000000000000000})`.
 */
contract Exponential is CarefulMath, ExponentialNoError {
    /**
     * @dev Creates an exponential from numerator and denominator values.
     *      Note: Returns an error if (`num` * 10e18) > MAX_INT,
     *            or if `denom` is zero.
     */
    function getExp(
        uint256 num,
        uint256 denom
    ) internal pure returns (MathError, Exp memory) {
        (MathError err0, uint256 scaledNumerator) = mulUInt(num, expScale);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        (MathError err1, uint256 rational) = divUInt(scaledNumerator, denom);
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: rational}));
    }

    /**
     * @dev Adds two exponentials, returning a new exponential.
     */
    function addExp(
        Exp memory a,
        Exp memory b
    ) internal pure returns (MathError, Exp memory) {
        (MathError error, uint256 result) = addUInt(a.mantissa, b.mantissa);

        return (error, Exp({mantissa: result}));
    }

    /**
     * @dev Subtracts two exponentials, returning a new exponential.
     */
    function subExp(
        Exp memory a,
        Exp memory b
    ) internal pure returns (MathError, Exp memory) {
        (MathError error, uint256 result) = subUInt(a.mantissa, b.mantissa);

        return (error, Exp({mantissa: result}));
    }

    /**
     * @dev Multiply an Exp by a scalar, returning a new Exp.
     */
    function mulScalar(
        Exp memory a,
        uint256 scalar
    ) internal pure returns (MathError, Exp memory) {
        (MathError err0, uint256 scaledMantissa) = mulUInt(a.mantissa, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: scaledMantissa}));
    }

    /**
     * @dev Multiply an Exp by a scalar, then truncate to return an unsigned integer.
     */
    function mulScalarTruncate(
        Exp memory a,
        uint256 scalar
    ) internal pure returns (MathError, uint256) {
        (MathError err, Exp memory product) = mulScalar(a, scalar);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return (MathError.NO_ERROR, truncate(product));
    }

    /**
     * @dev Multiply an Exp by a scalar, truncate, then add an to an unsigned integer, returning an unsigned integer.
     */
    function mulScalarTruncateAddUInt(
        Exp memory a,
        uint256 scalar,
        uint256 addend
    ) internal pure returns (MathError, uint256) {
        (MathError err, Exp memory product) = mulScalar(a, scalar);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return addUInt(truncate(product), addend);
    }

    /**
     * @dev Divide an Exp by a scalar, returning a new Exp.
     */
    function divScalar(
        Exp memory a,
        uint256 scalar
    ) internal pure returns (MathError, Exp memory) {
        (MathError err0, uint256 descaledMantissa) = divUInt(
            a.mantissa,
            scalar
        );
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: descaledMantissa}));
    }

    /**
     * @dev Divide a scalar by an Exp, returning a new Exp.
     */
    function divScalarByExp(
        uint256 scalar,
        Exp memory divisor
    ) internal pure returns (MathError, Exp memory) {
        /*
          We are doing this as:
          getExp(mulUInt(expScale, scalar), divisor.mantissa)
          How it works:
          Exp = a / b;
          Scalar = s;
          `s / (a / b)` = `b * s / a` and since for an Exp `a = mantissa, b = expScale`
        */
        (MathError err0, uint256 numerator) = mulUInt(expScale, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }
        return getExp(numerator, divisor.mantissa);
    }

    /**
     * @dev Divide a scalar by an Exp, then truncate to return an unsigned integer.
     */
    function divScalarByExpTruncate(
        uint256 scalar,
        Exp memory divisor
    ) internal pure returns (MathError, uint256) {
        (MathError err, Exp memory fraction) = divScalarByExp(scalar, divisor);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return (MathError.NO_ERROR, truncate(fraction));
    }

    /**
     * @dev Multiplies two exponentials, returning a new exponential.
     */
    function mulExp(
        Exp memory a,
        Exp memory b
    ) internal pure returns (MathError, Exp memory) {
        (MathError err0, uint256 doubleScaledProduct) = mulUInt(
            a.mantissa,
            b.mantissa
        );
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        // We add half the scale before dividing so that we get rounding instead of truncation.
        //  See "Listing 6" and text above it at https://accu.org/index.php/journals/1717
        // Without this change, a result like 6.6...e-19 will be truncated to 0 instead of being rounded to 1e-18.
        (MathError err1, uint256 doubleScaledProductWithHalfScale) = addUInt(
            halfExpScale,
            doubleScaledProduct
        );
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        (MathError err2, uint256 product) = divUInt(
            doubleScaledProductWithHalfScale,
            expScale
        );
        // The only error `div` can return is MathError.DIVISION_BY_ZERO but we control `expScale` and it is not zero.
        assert(err2 == MathError.NO_ERROR);

        return (MathError.NO_ERROR, Exp({mantissa: product}));
    }

    /**
     * @dev Multiplies two exponentials given their mantissas, returning a new exponential.
     */
    function mulExp(
        uint256 a,
        uint256 b
    ) internal pure returns (MathError, Exp memory) {
        return mulExp(Exp({mantissa: a}), Exp({mantissa: b}));
    }

    /**
     * @dev Multiplies three exponentials, returning a new exponential.
     */
    function mulExp3(
        Exp memory a,
        Exp memory b,
        Exp memory c
    ) internal pure returns (MathError, Exp memory) {
        (MathError err, Exp memory ab) = mulExp(a, b);
        if (err != MathError.NO_ERROR) {
            return (err, ab);
        }
        return mulExp(ab, c);
    }

    /**
     * @dev Divides two exponentials, returning a new exponential.
     *     (a/scale) / (b/scale) = (a/scale) * (scale/b) = a/b,
     *  which we can scale as an Exp by calling getExp(a.mantissa, b.mantissa)
     */
    function divExp(
        Exp memory a,
        Exp memory b
    ) internal pure returns (MathError, Exp memory) {
        return getExp(a.mantissa, b.mantissa);
    }
}

// File contracts/modules/transferRouter/interfaces/INextTransferRouter.sol

pragma solidity >=0.5.0;

interface INextTransferRouter {
    function transferFrom(
        string memory _project,
        address _token,
        address _from,
        address _to,
        uint256 _amount
    ) external;
}

// File contracts/modules/security/ReentrancyGuard.sol

// OpenZeppelin Contracts v4.4.0 (security/ReentrancyGuard.sol)

pragma solidity 0.8.11;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File contracts/interfaces/ISuperAdmin.sol

pragma solidity >=0.5.0;

interface ISuperAdmin {
    event NewPendingSuperAdmin(address pendingSuperAdmin);
    event NewSuperAdmin(address superAdmin);

    function superAdmin() external view returns (address);

    function pendingSuperAdmin() external view returns (address);

    function setPendingSuperAdmin(address _pendingSuperAdmin) external;

    function acceptSuperAdmin() external;
}

// File contracts/abstracts/SuperAdmin.sol

pragma solidity 0.8.11;

contract SuperAdmin is ISuperAdmin {
    address public override superAdmin;
    address public override pendingSuperAdmin;

    modifier onlySuperAdmin() {
        require(msg.sender == superAdmin, "Only Super Admin");
        _;
    }

    modifier onlyPendingSuperAdmin() {
        require(msg.sender == pendingSuperAdmin, "Only Pending Super Admin");
        _;
    }

    constructor(address superAdmin_) {
        superAdmin = superAdmin_;
    }

    function setPendingSuperAdmin(
        address _pendingSuperAdmin
    ) public onlySuperAdmin {
        pendingSuperAdmin = _pendingSuperAdmin;

        emit NewPendingSuperAdmin(pendingSuperAdmin);
    }

    function acceptSuperAdmin() public onlyPendingSuperAdmin {
        superAdmin = msg.sender;
        pendingSuperAdmin = address(0);

        emit NewSuperAdmin(superAdmin);
    }
}

// File contracts/interfaces/IBKNextCallHelper.sol

pragma solidity >=0.5.0;

interface IBKNextCallHelper {
    event CallHelperSet(address oldCallHelper, address newCallHelper);

    function callHelper() external returns (address);

    function setCallHelper(address _addr) external;
}

// File contracts/abstracts/BKNextCallHelper.sol

pragma solidity 0.8.11;

contract BKNextCallHelper is IBKNextCallHelper {
    address public override callHelper;

    modifier onlyCallHelper() {
        require(msg.sender == callHelper, "Only Callhelper");
        _;
    }

    constructor(address callHelper_) {
        callHelper = callHelper_;
    }

    function setCallHelper(address _addr) external override onlyCallHelper {
        address oldCallHelper = callHelper;
        callHelper = _addr;
        emit CallHelperSet(oldCallHelper, callHelper);
    }
}

// File contracts/abstracts/LendingStorage.sol

pragma solidity 0.8.11;

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

// File contracts/abstracts/LendingGetter.sol

pragma solidity 0.8.11;

abstract contract LendingGetter is LendingStorage {
    function exchangeRateStored() public view override returns (uint256) {
        (MathError err, uint256 result) = exchangeRateStoredInternal();
        require(err == MathError.NO_ERROR, "Math error");
        return result;
    }

    function exchangeRateStoredInternal()
        internal
        view
        returns (MathError, uint256)
    {
        uint256 _totalSupply = _lToken.totalSupply();
        if (_totalSupply == 0) {
            return (MathError.NO_ERROR, initialExchangeRateMantissa);
        } else {
            uint256 totalCash = getCashPrior();
            uint256 cashPlusBorrowsMinusReserves;
            Exp memory exchangeRate;
            MathError mathErr;

            (mathErr, cashPlusBorrowsMinusReserves) = addThenSubUInt(
                totalCash,
                totalBorrows,
                totalReserves()
            );
            if (mathErr != MathError.NO_ERROR) {
                return (mathErr, 0);
            }

            (mathErr, exchangeRate) = getExp(
                cashPlusBorrowsMinusReserves,
                _totalSupply
            );
            if (mathErr != MathError.NO_ERROR) {
                return (mathErr, 0);
            }

            return (MathError.NO_ERROR, exchangeRate.mantissa);
        }
    }

    function borrowBalanceStored(
        address account
    ) public view override returns (uint256) {
        (MathError err, uint256 result) = borrowBalanceStoredInternal(account);
        require(err == MathError.NO_ERROR, "Math error");
        return result;
    }

    function borrowBalanceStoredInternal(
        address account
    ) internal view returns (MathError, uint256) {
        MathError mathErr;
        uint256 principalTimesIndex;
        uint256 result;

        BorrowSnapshot storage borrowSnapshot = accountBorrows[account];

        if (borrowSnapshot.principal == 0) {
            return (MathError.NO_ERROR, 0);
        }

        (mathErr, principalTimesIndex) = mulUInt(
            borrowSnapshot.principal,
            borrowIndex
        );
        if (mathErr != MathError.NO_ERROR) {
            return (mathErr, 0);
        }

        (mathErr, result) = divUInt(
            principalTimesIndex,
            borrowSnapshot.interestIndex
        );
        if (mathErr != MathError.NO_ERROR) {
            return (mathErr, 0);
        }

        return (MathError.NO_ERROR, result);
    }

    function getAccountSnapshot(
        address account
    ) external view override returns (uint256, uint256, uint256, uint256) {
        uint256 lTokenBalance = _lToken.balanceOf(account);
        uint256 borrowBalance;
        uint256 exchangeRateMantissa;

        MathError mErr;

        (mErr, borrowBalance) = borrowBalanceStoredInternal(account);
        if (mErr != MathError.NO_ERROR) {
            return (uint256(Error.MATH_ERROR), 0, 0, 0);
        }

        (mErr, exchangeRateMantissa) = exchangeRateStoredInternal();
        if (mErr != MathError.NO_ERROR) {
            return (uint256(Error.MATH_ERROR), 0, 0, 0);
        }

        return (
            uint256(Error.NO_ERROR),
            lTokenBalance,
            borrowBalance,
            exchangeRateMantissa
        );
    }

    function borrowRatePerBlock() external view override returns (uint256) {
        return
            _interestRateModel.getBorrowRate(
                getCashPrior(),
                totalBorrows,
                totalReserves()
            );
    }

    function supplyRatePerBlock() external view override returns (uint256) {
        return
            _interestRateModel.getSupplyRate(
                getCashPrior(),
                totalBorrows,
                totalReserves(),
                reserveFactorMantissa()
            );
    }

    function reserveFactorMantissa() public view override returns (uint256) {
        uint256 sumReserveFactorMantissa = platformReserveFactorMantissa +
            poolReserveFactorMantissa;
        require(
            sumReserveFactorMantissa >= platformReserveFactorMantissa,
            "Overflow"
        );
        return sumReserveFactorMantissa;
    }

    function totalReserves() public view override returns (uint256) {
        uint256 sumReserves = platformReserves + poolReserves;
        require(sumReserves >= platformReserves, "Overflow");
        return sumReserves;
    }

    function controller() external view override returns (address) {
        return address(_controller);
    }

    function lToken() external view override returns (address) {
        return address(_lToken);
    }

    function transferRouter() external view override returns (address) {
        return address(_transferRouter);
    }

    function interestRateModel() external view override returns (address) {
        return address(_interestRateModel);
    }

    function getBlockNumber() internal view returns (uint256) {
        return block.number;
    }

    function getCash() external view override returns (uint256) {
        return getCashPrior();
    }

    function getCashPrior() internal view virtual returns (uint256);
}

// File contracts/abstracts/LendingInterest.sol

pragma solidity 0.8.11;

abstract contract LendingInterest is LendingGetter {
    struct AccrueInterestLocalVars {
        Error err;
        MathError mathErr;
        uint256 currentBlockNumber;
        uint256 accrualBlockNumberPrior;
        uint256 cashPrior;
        uint256 borrowsPrior;
        uint256 poolReservesPrior;
        uint256 platformReservesPrior;
        uint256 totalReservesPrior;
        uint256 borrowIndexPrior;
        uint256 borrowRateMantissa;
        uint256 blockDelta;
    }

    function accrueInterest() public override returns (uint256) {
        AccrueInterestLocalVars memory vars;

        vars.currentBlockNumber = getBlockNumber();
        vars.accrualBlockNumberPrior = accrualBlockNumber;

        if (vars.accrualBlockNumberPrior == vars.currentBlockNumber) {
            return uint256(Error.NO_ERROR);
        }

        vars.cashPrior = getCashPrior();
        vars.borrowsPrior = totalBorrows;
        vars.poolReservesPrior = poolReserves;
        vars.platformReservesPrior = platformReserves;
        vars.borrowIndexPrior = borrowIndex;

        vars.borrowRateMantissa = _interestRateModel.getBorrowRate(
            vars.cashPrior,
            vars.borrowsPrior,
            totalReserves()
        );

        require(
            vars.borrowRateMantissa <= borrowRateMaxMantissa,
            "Too high borrow rate"
        );

        (vars.mathErr, vars.blockDelta) = subUInt(
            vars.currentBlockNumber,
            vars.accrualBlockNumberPrior
        );
        require(
            vars.mathErr == MathError.NO_ERROR,
            "Calculate block delta failed"
        );

        Exp memory simpleInterestFactor;
        uint256 interestAccumulated;
        uint256 totalBorrowsNew;
        uint256 platformReservesNew;
        uint256 poolReservesNew;
        uint256 borrowIndexNew;

        (vars.mathErr, simpleInterestFactor) = mulScalar(
            Exp({mantissa: vars.borrowRateMantissa}),
            vars.blockDelta
        );
        if (vars.mathErr != MathError.NO_ERROR) {
            return
                failOpaque(
                    Error.MATH_ERROR,
                    FailureInfo
                        .ACCRUE_INTEREST_SIMPLE_INTEREST_FACTOR_CALCULATION_FAILED,
                    uint256(vars.mathErr)
                );
        }

        (vars.mathErr, interestAccumulated) = mulScalarTruncate(
            simpleInterestFactor,
            vars.borrowsPrior
        );
        if (vars.mathErr != MathError.NO_ERROR) {
            return
                failOpaque(
                    Error.MATH_ERROR,
                    FailureInfo
                        .ACCRUE_INTEREST_ACCUMULATED_INTEREST_CALCULATION_FAILED,
                    uint256(vars.mathErr)
                );
        }

        (vars.mathErr, totalBorrowsNew) = addUInt(
            interestAccumulated,
            vars.borrowsPrior
        );
        if (vars.mathErr != MathError.NO_ERROR) {
            return
                failOpaque(
                    Error.MATH_ERROR,
                    FailureInfo
                        .ACCRUE_INTEREST_NEW_TOTAL_BORROWS_CALCULATION_FAILED,
                    uint256(vars.mathErr)
                );
        }

        (vars.mathErr, platformReservesNew) = mulScalarTruncateAddUInt(
            Exp({mantissa: platformReserveFactorMantissa}),
            interestAccumulated,
            vars.platformReservesPrior
        );
        if (vars.mathErr != MathError.NO_ERROR) {
            return
                failOpaque(
                    Error.MATH_ERROR,
                    FailureInfo
                        .ACCRUE_INTEREST_NEW_PLATFORM_RESERVES_CALCULATION_FAILED,
                    uint256(vars.mathErr)
                );
        }

        (vars.mathErr, poolReservesNew) = mulScalarTruncateAddUInt(
            Exp({mantissa: poolReserveFactorMantissa}),
            interestAccumulated,
            vars.poolReservesPrior
        );
        if (vars.mathErr != MathError.NO_ERROR) {
            return
                failOpaque(
                    Error.MATH_ERROR,
                    FailureInfo
                        .ACCRUE_INTEREST_NEW_PLATFORM_RESERVES_CALCULATION_FAILED,
                    uint256(vars.mathErr)
                );
        }

        (vars.mathErr, borrowIndexNew) = mulScalarTruncateAddUInt(
            simpleInterestFactor,
            vars.borrowIndexPrior,
            vars.borrowIndexPrior
        );
        if (vars.mathErr != MathError.NO_ERROR) {
            return
                failOpaque(
                    Error.MATH_ERROR,
                    FailureInfo
                        .ACCRUE_INTEREST_NEW_BORROW_INDEX_CALCULATION_FAILED,
                    uint256(vars.mathErr)
                );
        }

        accrualBlockNumber = vars.currentBlockNumber;
        borrowIndex = borrowIndexNew;
        totalBorrows = totalBorrowsNew;
        platformReserves = platformReservesNew;
        poolReserves = poolReservesNew;

        emit AccrueInterest(
            vars.cashPrior,
            interestAccumulated,
            borrowIndexNew,
            totalBorrowsNew
        );

        return uint256(Error.NO_ERROR);
    }
}

// File contracts/abstracts/LendingSetter.sol

pragma solidity 0.8.11;

abstract contract LendingSetter is LendingInterest {
    function _setController(
        address newController
    ) public override onlySuperAdmin returns (uint256) {
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

    function _setControllerFresh(
        address newController
    ) internal returns (uint256) {
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

    function _setInterestRateModel(
        address newInterestRateModel
    ) public override onlySuperAdmin returns (uint256) {
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

    function _setInterestRateModelFresh(
        address newInterestRateModel
    ) internal returns (uint256) {
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

    function _setPlatformReserveFactor(
        uint256 newPlatformReserveFactorMantissa
    ) external override nonReentrant onlySuperAdmin returns (uint256) {
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

    function _setPoolReserveFactor(
        uint256 newPoolReserveFactorMantissa
    ) external override nonReentrant onlySuperAdmin returns (uint256) {
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

    function _setPoolReserveFactorFresh(
        uint256 newPoolReserveFactorMantissa
    ) internal returns (uint256) {
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

    function _setBeneficiary(
        address payable newBeneficiary
    ) external override nonReentrant returns (uint256) {
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

    function _setBeneficiaryFresh(
        address payable newBeneficiary
    ) internal returns (uint256) {
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

    function _setReservePool(
        address payable newReservePool
    ) external override nonReentrant returns (uint256) {
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

    function setTransferRouter(
        address newTransferRouter
    ) external override onlyCommittee returns (uint256) {
        _transferRouter = INextTransferRouter(newTransferRouter);
        return uint256(Error.NO_ERROR);
    }

    function _setReservePoolFresh(
        address payable newReservePool
    ) internal returns (uint256) {
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

// File contracts/interfaces/IYESVault.sol

pragma solidity >=0.5.0;

interface IYESVault {
    event Airdrop(address beneficiary, uint256 amount);
    event BorrowLimitUpdated(
        address account,
        uint256 oldAmount,
        uint256 newAmount
    );
    event Deposit(address sender, uint256 amount);
    event Withdraw(address sender, uint256 amount);

    function PROJECT() external view returns (string memory);

    function borrowLimitOf(address account) external view returns (uint256);

    function tokensOf(address account) external view returns (uint256);

    function releasedTo(address account) external view returns (uint256);

    function controller() external view returns (address);

    function yesToken() external view returns (address);

    function marketImpl() external view returns (address);

    function market() external view returns (address);

    function totalAllocated() external view returns (uint256);

    function admin() external view returns (address);

    function transferRouter() external view returns (address);

    function airdrop(address beneficiary, uint256 amount) external;

    function setBorrowLimit(address account, uint256 newAmount) external;

    function deposit(uint256 amount, address sender) external;

    function withdraw(uint256 amount, address sender) external;

    function sellMarket(
        address borrower,
        uint256 amount,
        uint256 deadline
    ) external payable returns (uint256);

    /*** Admin Events ***/

    event NewController(address oldController, address newController);
    event NewYESToken(address oldYESToken, address newYESToken);
    event NewMarketImpl(address oldMarketImpl, address newMarketImpl);
    event NewMarket(address oldMarket, address newMarket);
    event NewSlippageTolerrance(uint256 oldTolerrance, uint256 newTolerrance);
    event NewAdmin(address oldAdmin, address newAdmin);

    /*** Admin Functions ***/

    function setController(address newController) external;

    function setMarketImpl(address newMarketImpl) external;

    function setMarket(address newMarket) external;

    function setTransferRouter(address newTransferRouter) external;

    function setAdmin(address newAdmin) external;
}

// File contracts/abstracts/LendingContract.sol

pragma solidity 0.8.11;

abstract contract LendingContract is LendingSetter {
    constructor(
        ConstructorArgs memory args
    ) SuperAdmin(args.superAdmin) BKNextCallHelper(args.callHelper) {
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

        _lToken.burn(user, vars.withdrawTokens);

        doTransferOut(user, vars.withdrawAmount, method);

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

        accountBorrows[borrower].principal = vars.accountBorrowsNew;
        accountBorrows[borrower].interestIndex = borrowIndex;
        totalBorrows = vars.totalBorrowsNew;

        doTransferOut(borrower, borrowAmount, method);

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

    function borrowBalanceCurrent(
        address account
    ) external override nonReentrant returns (uint256) {
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

    function balanceOfUnderlying(
        address owner
    ) external override returns (uint256) {
        Exp memory exchangeRate = Exp({mantissa: exchangeRateCurrent()});
        (MathError mErr, uint256 balance) = mulScalarTruncate(
            exchangeRate,
            _lToken.balanceOf(owner)
        );
        require(mErr == MathError.NO_ERROR, "Math error");
        return balance;
    }

    /*** Protocol functions ***/

    function _claimPlatformReserves(
        uint256 claimedAmount
    ) external override returns (uint256) {
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

    function _claimPoolReserves(
        uint256 claimedAmount
    ) external override returns (uint256) {
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

// File contracts/KAP20Lending.sol

pragma solidity 0.8.11;

contract KAP20Lending is LendingContract {
    constructor(ConstructorArgs memory args) LendingContract(args) {}

    /*** User Interface ***/

    function deposit(
        uint256 depositAmount,
        address sender
    ) external returns (uint256) {
        uint256 err;
        if (msg.sender == callHelper) {
            requireKYC(sender);
            (err, ) = depositInternal(
                sender,
                depositAmount,
                TransferMethod.BK_NEXT
            );
        } else {
            (err, ) = depositInternal(
                msg.sender,
                depositAmount,
                TransferMethod.METAMASK
            );
        }

        return err;
    }

    function withdraw(
        uint256 withdrawTokens,
        address payable sender
    ) external returns (uint256) {
        uint256 err;
        if (msg.sender == callHelper) {
            requireKYC(sender);
            err = withdrawInternal(
                sender,
                withdrawTokens,
                TransferMethod.BK_NEXT
            );
        } else {
            err = withdrawInternal(
                payable(msg.sender),
                withdrawTokens,
                TransferMethod.METAMASK
            );
        }

        return err;
    }

    function withdrawUnderlying(
        uint256 withdrawAmount,
        address payable sender
    ) external returns (uint256) {
        uint256 err;
        if (msg.sender == callHelper) {
            requireKYC(sender);
            err = withdrawUnderlyingInternal(
                sender,
                withdrawAmount,
                TransferMethod.BK_NEXT
            );
        } else {
            err = withdrawUnderlyingInternal(
                payable(msg.sender),
                withdrawAmount,
                TransferMethod.METAMASK
            );
        }
        return err;
    }

    function borrow(
        uint256 borrowAmount,
        address payable sender
    ) external returns (uint256) {
        uint256 err;
        if (msg.sender == callHelper) {
            requireKYC(sender);
            err = borrowInternal(sender, borrowAmount, TransferMethod.BK_NEXT);
        } else {
            err = borrowInternal(
                payable(msg.sender),
                borrowAmount,
                TransferMethod.METAMASK
            );
        }
        return err;
    }

    function repayBorrow(
        uint256 repayAmount,
        address sender
    ) external returns (uint256) {
        uint256 err;
        if (msg.sender == callHelper) {
            requireKYC(sender);
            (err, ) = repayBorrowInternal(
                sender,
                repayAmount,
                TransferMethod.BK_NEXT
            );
        } else {
            (err, ) = repayBorrowInternal(
                msg.sender,
                repayAmount,
                TransferMethod.METAMASK
            );
        }
        return err;
    }

    function repayBorrowBehalf(
        address borrower,
        uint256 repayAmount,
        address sender
    ) external returns (uint256) {
        uint256 err;
        if (msg.sender == callHelper) {
            requireKYC(sender);
            requireKYC(borrower);
            (err, ) = repayBorrowBehalfInternal(
                sender,
                borrower,
                repayAmount,
                TransferMethod.BK_NEXT
            );
        } else {
            (err, ) = repayBorrowBehalfInternal(
                msg.sender,
                borrower,
                repayAmount,
                TransferMethod.METAMASK
            );
        }
        return err;
    }

    function liquidateBorrow(
        uint256 input,
        uint256 minReward,
        uint256 deadline,
        address borrower,
        address payable sender
    ) external returns (uint256) {
        uint256 err;

        if (msg.sender == callHelper) {
            requireKYC(sender);
            (err, ) = liquidateBorrowInternal(
                sender,
                borrower,
                input,
                minReward,
                deadline,
                TransferMethod.BK_NEXT
            );
        } else {
            (err, ) = liquidateBorrowInternal(
                payable(msg.sender),
                borrower,
                input,
                minReward,
                deadline,
                TransferMethod.METAMASK
            );
        }

        return err;
    }

    function sweepToken(IEIP20NonStandard token) external {
        require(msg.sender == beneficiary, "Only beneficiary");
        require(
            address(token) != underlyingToken,
            "Can not sweep underlying token"
        );
        uint256 balance = token.balanceOf(address(this));
        token.transfer(msg.sender, balance);
    }

    /*** Safe Token ***/

    function getCashPrior() internal view override returns (uint256) {
        return IKAP20(underlyingToken).balanceOf(address(this));
    }

    /**
     *      Note: This wrapper safely handles non-standard ERC-20 tokens that do not return a value.
     *            See here: https://medium.com/coinmonks/missing-return-value-bug-at-least-130-tokens-affected-d67bf08521ca
     */
    function doTransferIn(
        address from,
        uint256 amount,
        TransferMethod method
    ) internal override returns (uint256) {
        if (method == TransferMethod.BK_NEXT) {
            return doTransferInBKNext(from, amount);
        } else {
            return doTransferInMetamask(from, amount);
        }
    }

    function doTransferInBKNext(
        address from,
        uint256 amount
    ) private returns (uint256) {
        KAP20 token = KAP20(underlyingToken);
        uint256 balanceBefore = token.balanceOf(address(this));

        _transferRouter.transferFrom(
            PROJECT,
            address(token),
            from,
            address(this),
            amount
        );

        uint256 balanceAfter = token.balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "Transfer in overflow");
        return balanceAfter - balanceBefore; // underflow already checked above, just subtract
    }

    function doTransferInMetamask(
        address from,
        uint256 amount
    ) private returns (uint256) {
        IEIP20NonStandard token = IEIP20NonStandard(underlyingToken);
        uint256 balanceBefore = IKAP20(underlyingToken).balanceOf(
            address(this)
        );

        token.transferFrom(from, address(this), amount);

        bool success;
        assembly {
            switch returndatasize()
            case 0 {
                // This is a non-standard ERC-20
                success := not(0) // set success to true
            }
            case 32 {
                // This is a compliant ERC-20
                returndatacopy(0, 0, 32)
                success := mload(0) // Set `success = returndata` of external call
            }
            default {
                // This is an excessively non-compliant ERC-20, revert.
                revert(0, 0)
            }
        }
        require(success, "Transfer in failed");

        // Calculate the amount that was *actually* transferred
        uint256 balanceAfter = IKAP20(underlyingToken).balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "Transfer in overflow");
        return balanceAfter - balanceBefore; // underflow already checked above, just subtract
    }

    /**
     *      Note: This wrapper safely handles non-standard ERC-20 tokens that do not return a value.
     *            See here: https://medium.com/coinmonks/missing-return-value-bug-at-least-130-tokens-affected-d67bf08521ca
     */
    function doTransferOut(
        address payable to,
        uint256 amount,
        TransferMethod method
    ) internal override {
        method; //unused

        IEIP20NonStandard token = IEIP20NonStandard(underlyingToken);
        token.transfer(to, amount);

        bool success;
        assembly {
            switch returndatasize()
            case 0 {
                // This is a non-standard ERC-20
                success := not(0) // set success to true
            }
            case 32 {
                // This is a compliant ERC-20
                returndatacopy(0, 0, 32)
                success := mload(0) // Set `success = returndata` of external call
            }
            default {
                // This is an excessively non-compliant ERC-20, revert.
                revert(0, 0)
            }
        }

        require(success, "Transfer out failed");
    }
}
