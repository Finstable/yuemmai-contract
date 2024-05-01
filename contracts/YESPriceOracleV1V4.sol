//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./interfaces/IYESPriceOracle.sol";
import "./libraries/math/MathUtils.sol";
import "./modules/amm/interfaces/IUniswapV2Oracle.sol";
import "./interfaces/IPriceAggregator.sol";
import "./interfaces/IBKCOracleConsumer.sol";
import "./modules/access/Ownable.sol";

contract YESPriceOracleV1V4 is IYESPriceOracle, Ownable  {
    using MathUtils for uint256[];

    bool public constant override isPriceOracle = true;

    IUniswapV2Oracle public swapOracle;
    IBKCOracleConsumer public bkcOracleConsumer;
    address public kusdtToken;
    address public yesToken;

    address[] public stableCoins;
    mapping(address => address) public tokenAggregator;

    constructor(
        address swapOracle_,
        address bkcOracleConsumer_,
        address kusdtToken_,
        address yesToken_,
        address[] memory stableCoins_
    ) {
        swapOracle = IUniswapV2Oracle(swapOracle_);
        bkcOracleConsumer = IBKCOracleConsumer(bkcOracleConsumer_);
        kusdtToken = kusdtToken_;
        yesToken = yesToken_;
        for (uint256 i = 0; i < stableCoins_.length; i++) {
            stableCoins.push(stableCoins_[i]);
        }
    }

    /// @dev This function gives the result in KUSDT/YES symbol. For example, getYESPrice() = 1.7 means 1.7 YES = 1 KUSDT.
    /// Such that, 1 YES = 1 / 1.7 = 0.58 KUSDT
    /// This function gives varied decimal points depending on the token decimals, e.g., 18 for YES, KKUB, and KUSDT
    function getYESPrice() public view override returns (uint256) {
        uint256[] memory prices = new uint256[](stableCoins.length);

        for (uint256 i = 0; i < stableCoins.length; i++) {
            prices[i] = getLatestPrice(stableCoins[i]);
        }

        return prices.median(prices.length);
    }

    /// @dev This function gives the result in <token>/YES symbol, where <token> can be any supported token (e.g., KUB, KBTC, KUSDT, KUSDC, YES).
    /// For example, getLatestPrice(KBTC) = 2000 means 2000 YES = 1 KBTC. (Decimal point should be handled properly)
    function getLatestPrice(
        address token
    ) public view override returns (uint256) {
        if (token == yesToken) {
            return 1e18; // 1 YES = 1 YES
        } else if (token == stableCoins[0] || token == kusdtToken) {
            return swapOracle.consult(token, 1e18, yesToken); //e.g., KUSDT/YES => 0.4 YES = 1 USDT, 1 YES = 1 / 0.4 = 2.5 USDT
        } else {
            (, int256 answer, , , ) = bkcOracleConsumer.latestRoundData(tokenAggregator[token]); // Data retutned in 8 decimals from BKC oracle
            uint yesPrice = swapOracle.consult(yesToken, 1e18, stableCoins[0]); // YES/KUSDT => 1YES = 0.5 USDT (18 decimals)
            return uint256(answer) * 1e18 * 1e10 / yesPrice; // We want to retain 19 decimals. So, we do 8 decimals (answer) * 18 decimals * 10 decimals / 18 decimals (yesPrice) => 18 decimals
        }
    }

    function setAggregators(address[] memory tokens, address[] memory aggregators) external onlyOwner {
        require(tokens.length == aggregators.length, "Aggregator length mismatch");
         for (uint256 i = 0; i < tokens.length; i++) {
            tokenAggregator[tokens[i]] = aggregators[i];
        }
    }
}
