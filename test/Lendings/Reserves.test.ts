import { BigNumber } from "@ethersproject/bignumber";
import { formatEther, parseEther } from "@ethersproject/units";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { constants } from "ethers";
import { ethers } from "hardhat";
import time from "../../utils/timeUtils";
import { Contracts, deployYESSystem } from "../shared/setup";
import { enableBorrow } from "../shared/utils";

describe("Lendings - Reserves", () => {
  let contracts: Contracts;
  let senders: SignerWithAddress[];

  let owner: SignerWithAddress;
  let lender: SignerWithAddress;
  let borrower: SignerWithAddress;
  let liquidator: SignerWithAddress;
  let callHelper: SignerWithAddress;

  let depositAmount = parseEther("100");
  let borrowAmount = parseEther("0.099465");

  const borrowAndRepay = async () => {
    await contracts.kusdtLending
      .connect(borrower)
      .borrow(borrowAmount, borrower.address);

    for (let i = 0; i < 10; i++) {
      await time.advanceBlock();
    }

    return contracts.kusdtLending
      .connect(borrower)
      .repayBorrow(constants.MaxUint256, borrower.address);
  };

  const borrowAndRepayKUB = async () => {
    await contracts.kubLending
      .connect(borrower)
      .borrow(borrowAmount, borrower.address);

    for (let i = 0; i < 10; i++) {
      await time.advanceBlock();
    }

    await contracts.kkub
      .connect(borrower)
      .approve(contracts.kubLending.address, constants.MaxUint256);

    return contracts.kubLending
      .connect(borrower)
      .repayBorrow(borrowAmount, borrower.address);
  };

  beforeEach(async () => {
    senders = await ethers.getSigners();
    contracts = await deployYESSystem();

    owner = senders[0];
    lender = senders[1];
    borrower = senders[2];
    liquidator = senders[3];
    callHelper = senders[4];

    // Lender approve tokens to lending contract
    await contracts.kusdt
      .connect(lender)
      .approve(contracts.kusdtLending.address, depositAmount)
      .then((tx) => tx.wait());
    // Lender deposits tokens
    await contracts.kusdtLending
      .connect(lender)
      .deposit(depositAmount, lender.address)
      .then((tx) => tx.wait());

    await enableBorrow(contracts.yesVault, borrower.address);

    await contracts.kusdt
      .connect(borrower)
      .approve(contracts.kusdtLending.address, constants.MaxUint256);
    await contracts.kusdt.mint(borrower.address, parseEther("10000"));

    await contracts.kusdtLending._setPlatformReserveFactor(parseEther("0.1")); // 10%
    await contracts.kusdtLending._setPoolReserveFactor(parseEther("0.1")); // 10%
  });

  describe("reserve accumulation", () => {
    it("Should correctly accumulate reserves", async () => {
      const initialCash = await contracts.kusdtLending.getCash();

      await borrowAndRepay();

      const cash = await contracts.kusdtLending.getCash();
      const deltaCash = cash.sub(initialCash);
      const expectedPlatformReserve = deltaCash.mul("10").div("100");
      const expectedPoolReserve = deltaCash.mul("10").div("100");

      expect(
        Number(await contracts.kusdtLending.platformReserves())
      ).to.be.within(
        +expectedPlatformReserve.sub(100),
        +expectedPlatformReserve.add(100)
      );
      expect(Number(await contracts.kusdtLending.poolReserves())).to.be.within(
        +expectedPoolReserve.sub(100),
        +expectedPlatformReserve.add(100)
      );
    });
  });

  describe("reserve execution", () => {
    it("Should transfer to owner address", async function () {
      const beneficiary = owner.address;

      const initialOwnerTokens = await contracts.kusdt.balanceOf(beneficiary);

      await borrowAndRepay();
      const initialReserves = await contracts.kusdtLending.platformReserves();

      const claimedAmount = 10;

      await contracts.kusdtLending
        .connect(owner)
        ._claimPlatformReserves(claimedAmount);

      expect(await contracts.kusdt.balanceOf(beneficiary)).to.eq(
        initialOwnerTokens.add(claimedAmount)
      );
      expect(await contracts.kusdtLending.platformReserves()).to.eq(
        initialReserves.sub(claimedAmount)
      );
    });

    it("Should transfer to pool", async function () {
      const poolAddr = owner.address;

      const initialPoolToken = await contracts.kusdt.balanceOf(poolAddr);

      await borrowAndRepay();

      const initialReserves = await contracts.kusdtLending.poolReserves();

      const claimedAmount = 10;

      await contracts.kusdtLending
        .connect(owner)
        ._claimPoolReserves(claimedAmount)
        .then((tx) => tx.wait());

      expect(await contracts.kusdt.balanceOf(poolAddr)).to.eq(
        initialPoolToken.add(claimedAmount)
      );
      expect(await contracts.kusdtLending.poolReserves()).to.eq(
        initialReserves.sub(claimedAmount)
      );
    });
  });

  describe("reserve execution KUB", () => {
    beforeEach(async () => {
      const amount = parseEther("100");
      const [owner] = senders;
      await contracts.kubLending.deposit(amount, owner.address, {
        value: parseEther("100"),
      });
      await enableBorrow(contracts.yesVault, borrower.address);

      await contracts.kubLending._setPlatformReserveFactor(parseEther("0.1")); // 10%
      await contracts.kubLending._setPoolReserveFactor(parseEther("0.1")); // 10%
    });

    it("Should transfer to owner address", async function () {
      const beneficiary = owner.address;

      const initialOwnerTokens = await contracts.kkub.balanceOf(beneficiary);

      await borrowAndRepayKUB();

      const initialReserves = await contracts.kubLending.platformReserves();

      const claimedAmount = 100;

      await contracts.kubLending
        .connect(owner)
        ._claimPlatformReserves(claimedAmount);

      expect(await contracts.kkub.balanceOf(beneficiary)).to.eq(
        initialOwnerTokens.add(claimedAmount)
      );
      expect(await contracts.kubLending.platformReserves()).to.eq(
        initialReserves.sub(claimedAmount)
      );
    });

    it("Should transfer to pool address", async function () {
      const poolAddr = owner.address;

      const initialOwnerTokens = await contracts.kkub.balanceOf(poolAddr);

      await borrowAndRepayKUB();
      const initialReserves = await contracts.kubLending.poolReserves();

      const claimedAmount = 100;

      await contracts.kubLending
        .connect(owner)
        ._claimPoolReserves(claimedAmount);

      expect(await contracts.kkub.balanceOf(poolAddr)).to.eq(
        initialOwnerTokens.add(claimedAmount)
      );
      expect(await contracts.kubLending.poolReserves()).to.eq(
        initialReserves.sub(claimedAmount)
      );
    });
  });
});
