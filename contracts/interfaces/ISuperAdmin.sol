//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface ISuperAdmin {
    event NewPendingSuperAdmin(address pendingSuperAdmin);
    event NewSuperAdmin(address superAdmin);

    function superAdmin() external view returns (address);

    function pendingSuperAdmin() external view returns (address);

    function setPendingSuperAdmin(address _pendingSuperAdmin) external;

    function acceptSuperAdmin() external;
}
