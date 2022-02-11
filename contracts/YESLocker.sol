// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./modules/kap20/interfaces/IKAP20.sol";
import "./YESTicket.sol";
import "hardhat/console.sol";

contract YESLocker {
    uint public startAt;
    uint public endAt;
    uint public totalYesBalance;
    uint public totalYesWithdrawn;
    IKAP20 public yesToken;
    YESTicket public yesTicket;

    constructor(
        address yesToken_,
        address kyc_,
        address adminRouter_,
        address committee_,
        address transferRouter_,
        uint256 acceptedKYCLevel_
    ) {
        startAt = block.timestamp;
        endAt = block.timestamp + 10 minutes;
        yesToken = IKAP20(yesToken_);
        yesTicket = new YESTicket(
            kyc_,
            adminRouter_,
            committee_,
            transferRouter_,
            acceptedKYCLevel_
        );
    }

    function _getWithdrawablePortion() private view returns (uint256) {
        uint256 timeElapsed = block.timestamp - startAt;
        uint256 withdrawablePercent = ((timeElapsed * 100) / (endAt - startAt));
        return withdrawablePercent <= 100 ? withdrawablePercent : 100;
    }

    function depositToken(uint256 _amount) external {
        yesToken.transferFrom(msg.sender, address(this), _amount);
        totalYesBalance += _amount;
        yesTicket.mint(msg.sender, _amount);
    }

    function withdrawToken(uint _amount) external {
        console.log("Portion: ", _getWithdrawablePortion());

        uint256 maxSystemWithdrawableAmount = ((_getWithdrawablePortion()*totalYesBalance)/100) - totalYesWithdrawn;
        uint maxUserWithdrawbleAmount = yesTicket.balanceOf(msg.sender) >= maxSystemWithdrawableAmount ? maxSystemWithdrawableAmount : yesTicket.balanceOf(msg.sender);
        require(maxUserWithdrawbleAmount >= 0, "Insufficient Withdrawable Amount");

        if(_amount + totalYesWithdrawn >= maxUserWithdrawbleAmount){
            yesTicket.burn(msg.sender, maxUserWithdrawbleAmount);
            totalYesWithdrawn += maxUserWithdrawbleAmount;
            yesToken.transfer(msg.sender, maxUserWithdrawbleAmount);
        }else {
            yesTicket.burn(msg.sender, _amount);
            totalYesWithdrawn += _amount;
            yesToken.transfer(msg.sender, _amount);
        }
    }
}
