//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "../interfaces/ISuperAdmin.sol";

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

    function setPendingSuperAdmin(address _pendingSuperAdmin)
        public
        onlySuperAdmin
    {
        pendingSuperAdmin = _pendingSuperAdmin;

        emit NewPendingSuperAdmin(pendingSuperAdmin);
    }

    function acceptSuperAdmin() public onlyPendingSuperAdmin {
        superAdmin = msg.sender;
        pendingSuperAdmin = address(0);

        emit NewSuperAdmin(superAdmin);
    }
}
