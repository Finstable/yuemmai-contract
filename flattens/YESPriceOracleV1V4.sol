// Sources flattened with hardhat v2.8.4 https://hardhat.org

// File contracts/interfaces/IPriceOracle.sol

//SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IPriceOracle {
    function isPriceOracle() external view returns (bool);

    function getLatestPrice(address token) external view returns (uint256);
}


// File contracts/interfaces/IYESPriceOracle.sol

pragma solidity >=0.5.0;

interface IYESPriceOracle is IPriceOracle {
    event StableCoinAdded(address stableCoin, uint256 index);
    event StableCoinRemoved(address stableCoin, uint256 index);

    function getYESPrice() external view returns (uint256);
}


// File contracts/libraries/math/MathUtils.sol

pragma solidity >=0.5.0;

library MathUtils {
    function swap(
        uint256[] memory array,
        uint256 i,
        uint256 j
    ) internal pure {
        (array[i], array[j]) = (array[j], array[i]);
    }

    function sort(
        uint256[] memory array,
        uint256 begin,
        uint256 end
    ) internal pure {
        if (begin < end) {
            uint256 j = begin;
            uint256 pivot = array[j];
            for (uint256 i = begin + 1; i < end; ++i) {
                if (array[i] < pivot) {
                    swap(array, i, ++j);
                }
            }
            swap(array, begin, j);
            sort(array, begin, j);
            sort(array, j + 1, end);
        }
    }

    function median(uint256[] memory array, uint256 length)
        internal
        pure
        returns (uint256)
    {
        sort(array, 0, length);
        return
            length % 2 == 0
                ? (array[length / 2 - 1] + array[length / 2]) / 2
                : array[length / 2];
    }
}


// File contracts/modules/amm/interfaces/IUniswapV2Oracle.sol

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


// File contracts/interfaces/IPriceAggregator.sol

pragma solidity >=0.5.0;

// These contracts are derived from BKCOracle: https://docs.bkcoracle.com/utilities/data-feed-proxy-contract-interface.

interface AggregatorInterface {
  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);

  function latestRound() external view returns (uint256);

  function getAnswer(uint256 roundId) external view returns (int256);

  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);
  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}


// File contracts/shared/interfaces/AggregatorInterface/AggregatorV2V3Interface.sol

interface IPriceAggregator is AggregatorInterface, AggregatorV3Interface {}


// File contracts/interfaces/IBKCOracleConsumer.sol

pragma solidity >=0.5.0;

interface IBKCOracleConsumer {
    function latestRoundData(
        address aggregator
    )
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}


// File contracts/modules/misc/Context.sol

pragma solidity 0.8.11;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// File contracts/modules/access/Ownable.sol

// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

pragma solidity 0.8.11;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File contracts/YESPriceOracleV1V4.sol

pragma solidity 0.8.11;






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
