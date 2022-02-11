// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./interfaces/IKAP20.sol";
import "./interfaces/IKToken.sol";
import "../pause/Pausable.sol";
import "./interfaces/IKToken.sol";
import "../access/AccessController.sol";

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
