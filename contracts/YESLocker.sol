// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./YESTicket.sol";
import "./modules/kap20/interfaces/IKAP20.sol";

contract YESLocker {
    uint256 public startAt;
    uint256 public endAt;
    uint256 public totalYesBalance;
    uint256 public totalYesWithdrawn;
    IKAP20 public yesToken;
    YESTicket public yesTicket;

    event Locked(address sender, uint256 amount);
    event Withdrew(address sender, uint256 amount);

    constructor(
        uint256 startAt_,
        uint256 endAt_,
        address yesToken_,
        address kyc_,
        address adminRouter_,
        address committee_,
        address transferRouter_,
        uint256 acceptedKYCLevel_
    ) {
        require(endAt >= startAt, "End time must be after the start time");
        startAt = startAt_;
        endAt = endAt_;
        yesToken = IKAP20(yesToken_);
        yesTicket = new YESTicket(
            kyc_,
            adminRouter_,
            committee_,
            transferRouter_,
            acceptedKYCLevel_
        );
    }

    function getWithdrawablePortion() public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - startAt;
        uint256 withdrawablePercent = ((timeElapsed * 100) / (endAt - startAt));
        return withdrawablePercent <= 100 ? withdrawablePercent : 100;
    }

    function depositToken(uint256 _amount) external {
        yesToken.transferFrom(msg.sender, address(this), _amount);
        totalYesBalance += _amount;
        yesTicket.mint(msg.sender, _amount);

        emit Locked(msg.sender, _amount);
    }

    function withdrawToken(uint256 _amount) external {
        uint256 senderTicket = yesTicket.balanceOf(msg.sender);
        uint256 maxSystemWithdrawableAmount = ((getWithdrawablePortion() *
            totalYesBalance) / 100) - totalYesWithdrawn;
        uint256 maxUserWithdrawbleAmount = senderTicket >=
            maxSystemWithdrawableAmount
            ? maxSystemWithdrawableAmount
            : senderTicket;

        uint256 withdrawableAmount = (_amount + totalYesWithdrawn) >=
            maxUserWithdrawbleAmount
            ? maxUserWithdrawbleAmount
            : _amount;

        yesTicket.burn(msg.sender, withdrawableAmount);
        totalYesWithdrawn += withdrawableAmount;
        yesToken.transfer(msg.sender, withdrawableAmount);

        emit Withdrew(msg.sender, withdrawableAmount);
    }
}
