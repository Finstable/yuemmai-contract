//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./modules/kap20/KAP20.sol";

contract LToken is KAP20 {
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _kyc,
        address _adminProjectRouter,
        address _committee,
        address _transferRouter,
        uint256 _acceptedKYCLevel
    )
        KAP20(
            _name,
            _symbol,
            "bitkub-next-yuemmai",
            _decimals,
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
