//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IYESVault {
    event Airdrop(address beneficiary, uint256 amount);
    event BorrowLimitUpdated(
        address account,
        uint256 oldAmount,
        uint256 newAmount
    );
    event Deposit(address sender, uint256 amount);
    event Withdraw(address sender, uint256 amount);

    function PROJECT() external view returns (string memory);

    function borrowLimitOf(address account) external view returns (uint256);

    function tokensOf(address account) external view returns (uint256);

    function releasedTo(address account) external view returns (uint256);

    function controller() external view returns (address);

    function yesToken() external view returns (address);

    function marketImpl() external view returns (address);

    function market() external view returns (address);

    function totalAllocated() external view returns (uint256);

    function admin() external view returns (address);

    function airdrop(address beneficiary, uint256 amount) external;

    function setBorrowLimit(address account, uint256 newAmount) external;

    function deposit(uint256 amount, address sender) external;

    function withdraw(uint256 amount, address sender) external;

    function sellMarket(
        address borrower,
        uint256 amount,
        uint256 deadline
    ) external payable returns (uint256);

    /*** Admin Events ***/

    event NewController(address oldController, address newController);
    event NewYESToken(address oldYESToken, address newYESToken);
    event NewMarketImpl(address oldMarketImpl, address newMarketImpl);
    event NewMarket(address oldMarket, address newMarket);
    event NewSlippageTolerrance(uint256 oldTolerrance, uint256 newTolerrance);
    event NewAdmin(address oldAdmin, address newAdmin);

    /*** Admin Functions ***/

    function setController(address newController) external;

    function setMarketImpl(address newMarketImpl) external;

    function setMarket(address newMarket) external;

    function setAdmin(address newAdmin) external;
}
