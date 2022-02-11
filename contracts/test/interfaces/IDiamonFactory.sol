pragma solidity 0.6.7;

interface IDiamonFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function getAcceptedLV() external view returns (uint256);

    function getCommittee() external view returns (address);

    function getAdminRounter() external view returns (address);

    function getKYC() external view returns (address);
}