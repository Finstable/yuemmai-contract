//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./modules/kap20/KAP20.sol";

contract YESTicket is KAP20 {
    constructor(
        address _kyc,
        address _adminProjectRouter,
        address _committee,
        address _transferRouter,
        uint256 _acceptedKYCLevel
    )
        KAP20(
            "YES Ticket",
            "TYES",
            "bitkub-next-yuemmai",
            18,
            _kyc,
            _adminProjectRouter,
            _committee,
            _transferRouter,
            _acceptedKYCLevel
        )
    {}

    function mint(address _to, uint256 _amount) external onlyOwner {
        _mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) external onlyOwner {
        _burn(_from, _amount);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
