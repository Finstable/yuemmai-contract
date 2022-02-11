pragma solidity 0.6.7;

interface IKAP20AdminApprove {
    function adminApprove(
        address _owner,
        address _spender,
        uint256 _amount
    ) external returns (bool);
}
