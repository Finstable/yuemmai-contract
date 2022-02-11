pragma solidity 0.6.7;

interface IKAP20Committee {
    function committee() external view returns (address);

    function setCommittee(address _committee) external;
}