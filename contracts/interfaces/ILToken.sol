//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

import "../modules/kap20/interfaces/IKAP20.sol";
import "../modules/kap20/interfaces/IKToken.sol";
import "../modules/kyc/interfaces/IKAP20KYC.sol";

interface ILToken is IKAP20, IKToken, IKAP20KYC {
    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;
}
