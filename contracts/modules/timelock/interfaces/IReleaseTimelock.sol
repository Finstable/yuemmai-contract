// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IReleaseTimelock {
    function releaseTime() external view returns (uint256);
}
