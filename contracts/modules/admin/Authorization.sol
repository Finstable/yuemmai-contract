// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./interfaces/IAdminProjectRouter.sol";

abstract contract Authorization {
    IAdminProjectRouter public adminProjectRouter;
    string public PROJECT;

    event AdminProjectRouterSet(address indexed oldAdmin, address indexed newAdmin, address indexed caller);

    modifier onlySuperAdmin() {
        require(adminProjectRouter.isSuperAdmin(msg.sender, PROJECT), "Authorization: restricted only super admin");
        _;
    }

    modifier onlyAdmin() {
        require(adminProjectRouter.isAdmin(msg.sender, PROJECT), "Authorization: restricted only admin");
        _;
    }

    modifier onlySuperAdminOrAdmin() {
        require(
            adminProjectRouter.isSuperAdmin(msg.sender, PROJECT) || adminProjectRouter.isAdmin(msg.sender, PROJECT),
            "Authorization: restricted only super admin or admin"
        );
        _;
    }

    function setAdminProjectRouter(address _adminProjectRouter) public virtual onlySuperAdmin {
        require(_adminProjectRouter != address(0), "Authorization: new admin project router is the zero address");
        emit AdminProjectRouterSet(address(adminProjectRouter), _adminProjectRouter, msg.sender);
        adminProjectRouter = IAdminProjectRouter(_adminProjectRouter);
    }
}