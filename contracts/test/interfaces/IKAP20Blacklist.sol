pragma solidity 0.6.7;

interface IKAP20Blacklist {
    function addBlacklist(address _addr) external;

    function revokeBlacklist(address _addr) external;
}
