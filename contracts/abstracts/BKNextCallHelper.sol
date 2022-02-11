//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "../interfaces/IBKNextCallHelper.sol";

contract BKNextCallHelper is IBKNextCallHelper {
    address public override callHelper;

    modifier onlyCallHelper() {
        require(msg.sender == callHelper, "Only Callhelper");
        _;
    }

    constructor(address callHelper_) {
        callHelper = callHelper_;
    }

    function setCallHelper(address _addr) external override onlyCallHelper {
        address oldCallHelper = callHelper;
        callHelper = _addr;
        emit CallHelperSet(oldCallHelper, callHelper);
    }
}
