pragma solidity 0.6.7;

interface IKYCBitkubChain {
    function kycsLevel(address _addr) external view returns (uint256);
}
