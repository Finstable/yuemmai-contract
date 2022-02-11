// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "../admin/Authorization.sol";
import "../kyc/KYCHandler.sol";
import "../access/Ownable.sol";
import "../committee/Committee.sol";

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

    function setTransferRouter(address _transferRouter)
        external
        onlyOwnerOrCommittee
    {
        emit TransferRouterSet(transferRouter, _transferRouter, msg.sender);
        transferRouter = _transferRouter;
    }

    function setAdminProjectRouter(address _adminProjectRouter)
        public
        override
        onlyOwnerOrCommittee
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
