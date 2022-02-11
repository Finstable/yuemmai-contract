//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./modules/kap20/KAP20.sol";

contract YESToken is KAP20 {

    constructor(
        uint256 _totalSupply,
        address _kyc,
        address _adminProjectRouter,
        address _committee,
        address _transferRouter,
        uint256 _acceptedKYCLevel
    )
        KAP20(
            "YES Token",
            "YES",
            "bitkub-next-yuemmai",
            18,
            _kyc,
            _adminProjectRouter,
            _committee,
            _transferRouter,
            _acceptedKYCLevel
        )
    {
        _mint(msg.sender, _totalSupply);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

}