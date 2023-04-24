//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IYESPriceFeed {
    function getOraclePrice(address token) external view returns (uint);
}
