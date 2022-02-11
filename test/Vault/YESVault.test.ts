import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import hre from "hardhat";
import time from "../../utils/timeUtils";
import { Contracts, deployYESSystem } from "../shared/setup";

describe("YESVault", () => {
  let senders: SignerWithAddress[];

  let owner: SignerWithAddress;
  let lender: SignerWithAddress;
  let borrower: SignerWithAddress;
  let callHelper: SignerWithAddress;

  let contracts: Contracts;

  const airdropAmount = hre.ethers.utils.parseEther("166.7");

  async function updatePrice() {
    await contracts.slidingWindowOracle
      .update(contracts.kkub.address, contracts.yes.address)
      .then((tx) => tx.wait());
    await contracts.slidingWindowOracle
      .update(contracts.kusdt.address, contracts.yes.address)
      .then((tx) => tx.wait());
  }

  beforeEach(async function () {
    senders = await hre.ethers.getSigners();
    contracts = await deployYESSystem();

    owner = senders[0];
    lender = senders[1];
    borrower = senders[2];
    callHelper = senders[4];
  });

  describe("Token Airdrop", function () {
    it("Should correctly releases tokens", async function () {
      await contracts.yesVault
        .airdrop(borrower.address, airdropAmount)
        .then((tx) => tx.wait());
      expect(await contracts.yesVault.tokensOf(borrower.address)).to.eq(
        airdropAmount
      );
      expect(await contracts.yesVault.totalAllocated()).to.eq(airdropAmount);
    });

    it("Should locks tokens before release time", async function () {
      await expect(
        contracts.yesVault.connect(borrower).withdraw(airdropAmount, borrower.address)
      ).to.be.revertedWith("TokenTimelock: TIME_LOCKED");
    });

    it("Should unlocks tokens after release time", async function () {
      await contracts.yesVault
        .airdrop(borrower.address, airdropAmount)
        .then((tx) => tx.wait());

      const alicePreBalance = await contracts.yes.balanceOf(borrower.address);
      const yesVaultPreBalance = await contracts.yes.balanceOf(
        contracts.yesVault.address
      );
      const preAllocated = await contracts.yesVault.totalAllocated();

      await time.increase(time.duration.years(1) + time.duration.days(7));
      await updatePrice();
      await time.increase(time.duration.minutes(5));

      await contracts.yesVault.connect(borrower).withdraw(airdropAmount, borrower.address);

      expect(await contracts.yes.balanceOf(borrower.address)).to.eq(
        alicePreBalance.add(airdropAmount)
      );
      expect(await contracts.yes.balanceOf(contracts.yesVault.address)).to.eq(
        yesVaultPreBalance.sub(airdropAmount)
      );
      expect(await contracts.yesVault.totalAllocated()).to.eq(
        preAllocated.sub(airdropAmount)
      );
    });
  });

  describe("Deposit", function () {
    it("Should correctly deposit", async function () {
      const [owner] = senders;

      const preSenderBalance = await contracts.yes.balanceOf(owner.address);
      const preVaultBalance = await contracts.yes.balanceOf(
        contracts.yesVault.address
      );
      const preTokens = await contracts.yesVault.tokensOf(owner.address);

      await contracts.yes.approve(contracts.yesVault.address, airdropAmount);
      await contracts.yesVault.deposit(airdropAmount, owner.address);

      expect(await contracts.yes.balanceOf(owner.address)).to.eq(
        preSenderBalance.sub(airdropAmount)
      );
      expect(await contracts.yes.balanceOf(contracts.yesVault.address)).to.eq(
        preVaultBalance.add(airdropAmount)
      );
      expect(await contracts.yesVault.tokensOf(owner.address)).to.eq(
        preTokens.add(airdropAmount)
      );
    });
  });

  describe("Deposit/Withdraw BK Next", function () {
    it("Should correctly deposit", async function () {
      await contracts.yes.transfer(borrower.address, airdropAmount);

      const preSenderBalance = await contracts.yes.balanceOf(borrower.address);
      const preVaultBalance = await contracts.yes.balanceOf(
        contracts.yesVault.address
      );
      const preTokens = await contracts.yesVault.tokensOf(borrower.address);

      await contracts.yesVault
        .connect(callHelper)
        .deposit(airdropAmount, borrower.address);

      expect(await contracts.yes.balanceOf(borrower.address)).to.eq(
        preSenderBalance.sub(airdropAmount)
      );
      expect(await contracts.yes.balanceOf(contracts.yesVault.address)).to.eq(
        preVaultBalance.add(airdropAmount)
      );
      expect(await contracts.yesVault.tokensOf(borrower.address)).to.eq(
        preTokens.add(airdropAmount)
      );
    });

    it("Should correctly withdraw", async function () {
      await contracts.yesVault
        .airdrop(borrower.address, airdropAmount)
        .then((tx) => tx.wait());

      const borrowerPreBalance = await contracts.yes.balanceOf(
        borrower.address
      );
      const yesVaultPreBalance = await contracts.yes.balanceOf(
        contracts.yesVault.address
      );
      const preAllocated = await contracts.yesVault.totalAllocated();

      await time.increase(time.duration.years(1) + time.duration.days(7));
      await updatePrice();
      await time.increase(time.duration.minutes(5));

      await contracts.yesVault
        .connect(callHelper)
        .withdraw(airdropAmount, borrower.address);

      expect(await contracts.yes.balanceOf(borrower.address)).to.eq(
        borrowerPreBalance.add(airdropAmount)
      );
      expect(await contracts.yes.balanceOf(contracts.yesVault.address)).to.eq(
        yesVaultPreBalance.sub(airdropAmount)
      );
      expect(await contracts.yesVault.totalAllocated()).to.eq(
        preAllocated.sub(airdropAmount)
      );
    });
  });
});
