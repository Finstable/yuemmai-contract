//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IUniswapV2Oracle {
    struct Observation {
        uint256 timestamp;
        uint256 price0Cumulative;
        uint256 price1Cumulative;
    }

    function factory() external view returns (address);

    function windowSize() external view returns (uint256);

    function granularity() external view returns (uint8);

    function periodSize() external view returns (uint256);

    function pairObservations(address addr, uint256 index)
        external
        view
        returns (Observation calldata);

    function observationIndexOf(uint256 timestamp)
        external
        view
        returns (uint8);

    function consult(
        address tokenIn,
        uint256 amountIn,
        address tokenOut
    ) external view returns (uint256);

    function update(address tokenA, address tokenB) external;
}
