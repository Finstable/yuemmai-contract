//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

interface IAdminProjectRouter {
    function isSuperAdmin(address _addr, string calldata _project) external view returns (bool);

    function isAdmin(address _addr, string calldata _project) external view returns (bool);
}