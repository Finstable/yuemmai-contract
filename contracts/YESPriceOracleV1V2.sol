//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./interfaces/IYESPriceOracle.sol";
import "./libraries/math/MathUtils.sol";
import "./modules/amm/interfaces/IUniswapV2Oracle.sol";
import "./interfaces/IYESPriceFeed.sol";

contract YESPriceOracleV1V2 is IYESPriceOracle {
    using MathUtils for uint256[];

    bool public constant override isPriceOracle = true;

    IUniswapV2Oracle public swapOracle;
    address public yesToken;
    IYESPriceFeed public yesPriceFeed;

    address[] public stableCoins;

    constructor(
        address swapOracle_,
        address yesToken_,
        address[] memory stableCoins_,
        address yesPriceFeed_
    ) {
        swapOracle = IUniswapV2Oracle(swapOracle_);
        yesToken = yesToken_;
        for (uint256 i = 0; i < stableCoins_.length; i++) {
            stableCoins.push(stableCoins_[i]);
        }
        yesPriceFeed = IYESPriceFeed(yesPriceFeed_);
    }

    function getYESPrice() public view override returns (uint256) {
        uint256[] memory prices = new uint256[](stableCoins.length);

        for (uint256 i = 0; i < stableCoins.length; i++) {
            prices[i] = getLatestPrice(stableCoins[i]);
        }

        return prices.median(prices.length);
    }

    function getLatestPrice(
        address token
    ) public view override returns (uint256) {
        if (token == yesToken) {
            return 1e18;
        } else if (token == stableCoins[0]) {
            return swapOracle.consult(token, 1e18, yesToken);
        } else {
            uint tokenPrice = yesPriceFeed.getOraclePrice(token) * 1e18;
            uint yesPrice = swapOracle.consult(yesToken, 1e18, stableCoins[0]);
            return tokenPrice / yesPrice;
        }
    }
}
