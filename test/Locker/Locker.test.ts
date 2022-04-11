import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import timeUtils from "../../utils/timeUtils";
import { Contracts, deployYESSystem } from "../shared/setup";

describe("Lending - AccrueInterest", () => {
  let contracts: Contracts;
  let senders: SignerWithAddress[];

  let owner: SignerWithAddress;

  beforeEach(async () => {
    senders = await ethers.getSigners();
    contracts = await deployYESSystem();

    owner = senders[0];
  });

  describe("deposit", () => {
    it("should accept deposit", async () => {
      const yesBal = await contracts.yes.balanceOf(owner.address);
      await contracts.yes.approve(contracts.locker.address, yesBal);
      await contracts.locker.depositToken(yesBal);
      expect(await contracts.yes.balanceOf(owner.address)).to.eq("0");
      expect(await contracts.yes.balanceOf(contracts.locker.address)).to.eq(
        yesBal
      );
      expect(await contracts.yesTicket.balanceOf(owner.address)).to.eq(yesBal);
    });
  });

  describe("withdraw", () => {
    beforeEach(async () => {
      const yesBal = await contracts.yes.balanceOf(owner.address);
      await contracts.yes.approve(contracts.locker.address, yesBal);
      await contracts.locker.depositToken(yesBal);
    });

    it("should lock maximum withdraw amount", async () => {
      const allTickets = await contracts.yesTicket.balanceOf(owner.address);
      await timeUtils.increase(timeUtils.duration.hours(1));
      await contracts.locker.withdrawToken(allTickets);
      expect(await contracts.yes.balanceOf(owner.address)).to.lt(allTickets);
    });

    it("should allow withdraw after locking", async () => {
      const initialLockerBal = await contracts.yes.balanceOf(
        contracts.locker.address
      );
      const initialTicket = await contracts.yesTicket.balanceOf(owner.address);
      await timeUtils.increase(timeUtils.duration.hours(12));
      const totalLocked = await contracts.locker.totalYesBalance();
      const withdrawAmount = totalLocked.div(2);
      await contracts.locker.withdrawToken(withdrawAmount);
      expect(await contracts.yes.balanceOf(owner.address)).to.eq(
        withdrawAmount
      );
      expect(await contracts.yes.balanceOf(contracts.locker.address)).to.eq(
        initialLockerBal.sub(withdrawAmount)
      );
      expect(await contracts.yesTicket.balanceOf(owner.address)).to.eq(
        initialTicket.sub(withdrawAmount)
      );
    });
  });
});
