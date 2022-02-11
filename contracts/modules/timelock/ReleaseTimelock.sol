// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./interfaces/IReleaseTimelock.sol";

contract ReleaseTimelock is IReleaseTimelock {
    uint256 private immutable _releaseTime;

    modifier onlyUnlocked() {
        require(block.timestamp >= _releaseTime, "TokenTimelock: TIME_LOCKED");
        _;
    }

    constructor(uint256 releaseTime_) {
        // require(releaseTime_ > block.timestamp, "TokenTimelock: INVALID_RELEASE_TIME");
        _releaseTime = releaseTime_;
    }

    function releaseTime() external view override returns (uint256) {
        return _releaseTime;
    }
}
