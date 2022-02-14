// SPDX-License-Identifier: MIT
// Sources flattened with hardhat v2.5.0 https://hardhat.org

// File contracts/interfaces/IAdminProjectRouter.sol

pragma solidity >=0.6.0 <0.9.0;

interface IAdminProjectRouter {
    function isSuperAdmin(address _addr, string calldata _project)
        external
        view
        returns (bool);

    function isAdmin(address _addr, string calldata _project)
        external
        view
        returns (bool);
}

// File contracts/abstracts/standard/Authorization.sol

pragma solidity ^0.8.0;

abstract contract Authorization {
    IAdminProjectRouter public adminProjectRouter;
    string public PROJECT; // Fill the project name

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

    function setAdminProjectRouter(address _adminProjectRouter)
        public
        virtual
        onlySuperAdmin
    {
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

// File contracts/interfaces/IKYCBitkubChain.sol

pragma solidity >=0.6.0 <0.9.0;

interface IKYCBitkubChain {
    function kycsLevel(address _addr) external view returns (uint256);
}

// File contracts/abstracts/standard/KYCHandler.sol

pragma solidity ^0.8.0;

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

// File contracts/abstracts/Committee.sol

pragma solidity ^0.8.0;

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

// File contracts/abstracts/Context.sol

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File contracts/abstracts/Ownable.sol

pragma solidity ^0.8.0;

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

// File contracts/abstracts/AccessController.sol

pragma solidity ^0.8.0;

abstract contract AccessController is Authorization, KYCHandler, Committee {
    address public transferRouter;

    event TransferRouterSet(
        address indexed oldTransferRouter,
        address indexed newTransferRouter,
        address indexed caller
    );

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

    function activateOnlyKYCAddress() external onlyCommittee {
        _activateOnlyKYCAddress();
    }

    function setKYC(address _kyc) external onlyCommittee {
        _setKYC(_kyc);
    }

    function setAcceptedKYCLevel(uint256 _kycLevel) external onlyCommittee {
        _setAcceptedKYCLevel(_kycLevel);
    }

    function setTransferRouter(address _transferRouter) external onlyCommittee {
        emit TransferRouterSet(transferRouter, _transferRouter, msg.sender);
        transferRouter = _transferRouter;
    }

    function setAdminProjectRouter(address _adminProjectRouter)
        public
        override
        onlyCommittee
    {
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

// File contracts/abstracts/standard/Pausable.sol

pragma solidity ^0.8.0;

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

// File contracts/interfaces/IKAP20/IKAP20.sol

pragma solidity >=0.6.0 <0.9.0;

interface IKAP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

// File contracts/interfaces/IKToken.sol

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

// File contracts/token/KAP20.sol

pragma solidity ^0.8.0;

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

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        whenNotPaused
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
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

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
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

// File contracts/KUSDC_new.sol

pragma solidity ^0.8.0;

contract TestKUSDC is KAP20 {
    constructor(
        address _kyc,
        address _adminProjectRouter,
        address _committee,
        address _transferRouter, // admin kap 20 router
        uint256 _acceptedKYCLevel
    )
        KAP20(
            "KUSDT",
            "KUSDT",
            "KUSDT",
            18,
            _kyc,
            _adminProjectRouter,
            _committee,
            _transferRouter,
            _acceptedKYCLevel
        )
    {}

    function pause() external onlyCommittee {
        _pause();
    }

    function unpause() external onlyCommittee {
        _unpause();
    }

    ///////////////////////////////////////////////////////////////////////////////////////

    function mint(address _to, uint256 _amount)
        external
        // onlyCommittee
        whenNotPaused
    {
        _mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount)
        external
        // onlyCommittee
        whenNotPaused
    {
        _burn(_from, _amount);
    }
}
