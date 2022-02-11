pragma solidity 0.6.7;

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