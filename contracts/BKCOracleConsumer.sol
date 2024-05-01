//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./interfaces/IPriceAggregator.sol";

contract BKCOracleConsumer {
    function latestRoundData(
        address aggregator
    )
        public
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        (
            roundId,
            answer,
            startedAt,
            updatedAt,
            answeredInRound
        ) = IPriceAggregator(aggregator).latestRoundData();
        return (roundId, answer, startedAt, updatedAt, answeredInRound);
    }
}
