pragma solidity 0.6.7;

interface IKAP20KYC {
    function activateOnlyKycAddress() external;

    function setKYC(address _kyc) external;

    function setAcceptedKycLevel(uint256 _kycLevel) external;
}