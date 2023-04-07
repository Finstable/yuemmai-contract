//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

import "./ILToken.sol";

interface ILKAP20 is ILToken {
    function mint(uint256 mintAmount) external returns (uint256);

    function withdraw(uint256 withdrawTokens) external returns (uint256);

    function withdrawUnderlying(
        uint256 withdrawAmount
    ) external returns (uint256);

    function borrow(uint256 borrowAmount) external returns (uint256);

    function repayBorrow(uint256 repayAmount) external returns (uint256);
}
