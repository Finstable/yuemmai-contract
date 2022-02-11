//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IBKNextCallHelper {
    event CallHelperSet(address oldCallHelper, address newCallHelper);

    function callHelper() external returns (address);

    function setCallHelper(address _addr) external;
}
