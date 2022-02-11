import { parseEther } from "@ethersproject/units";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { constants } from "ethers";
import { ethers } from "hardhat";
import { TokenError, TokenFailureInfo } from "../shared/error";
import { Contracts, deployYESSystem } from "../shared/setup";
import { Change, enableBorrow, expectTokenChanges } from "../shared/utils";

describe("Lendings - BorrowAndRepayKUB", () => {
  let contracts: Contracts;
  let senders: SignerWithAddress[];

  let owner: SignerWithAddress;
  let lender: SignerWithAddress;
  let borrower: SignerWithAddress;
  let callHelper: SignerWithAddress;

  const depositAmount = parseEther("100");
  const borrowAmount = parseEther("10");

  beforeEach(async () => {
    senders = await ethers.getSigners();
    contracts = await deployYESSystem();

    owner = senders[0];
    lender = senders[1];
    borrower = senders[2];
    callHelper = senders[4];
  });

  describe("borrowKUB", () => {
    it("fails if protocol has less than borrowAmount of underlying", async () => {
      // Increase borrower's collateral balance and borrow limit
      await enableBorrow(contracts.yesVault, borrower.address);

      // Expect borrowing to fail due to insufficient liquidity
      expect(
        await contracts.kubLending
          .connect(borrower)
          .borrow(borrowAmount, borrower.address)
      )
        .to.emit(contracts.kubLending, "Failure")
        .withArgs(
          TokenError.TOKEN_INSUFFICIENT_CASH,
          TokenFailureInfo.BORROW_CASH_NOT_AVAILABLE,
          0
        );
    });

    it("Should correctly lends tokens", async function () {
      // Lender approve tokens to lending contract
      await contracts.kubLending
        .connect(borrower)
        .deposit(borrowAmount, borrower.address, { value: borrowAmount });
      await enableBorrow(contracts.yesVault, borrower.address);

      // Expect borrowing to fail due to insufficient liquidity
      await expectTokenChanges(
        () =>
          contracts.kubLending
            .connect(borrower)
            .borrow(borrowAmount, borrower.address),
        contracts.kkub,
        [borrower.address, contracts.kubLending.address],
        [borrowAmount, borrowAmount],
        [Change.INC, Change.DEC]
      );
    });
  });

  describe("repayBorrow KUB", () => {
    beforeEach(async () => {
      // Supply KUB to system
      await contracts.kubLending
        .connect(lender)
        .deposit(depositAmount, lender.address, { value: depositAmount });
      await enableBorrow(contracts.yesVault, borrower.address);
    });

    it("Should correctly operates repayment", async function () {
      // Borrow
      await contracts.kubLending
        .connect(borrower)
        .borrow(borrowAmount, borrower.address);

      // Approve KKUB
      await contracts.kkub
        .connect(borrower)
        .approve(contracts.kubLending.address, constants.MaxUint256);

      // Repay borrow
      await expectTokenChanges(
        () =>
          contracts.kubLending
            .connect(borrower)
            .repayBorrow(borrowAmount, borrower.address),
        contracts.kkub,
        [borrower.address, contracts.kubLending.address],
        [borrowAmount, borrowAmount],
        [Change.DEC, Change.INC]
      );
    });

    it("Should correctly operates withdraw", async function () {
      // Deposit
      await contracts.kubLending
        .connect(lender)
        .deposit(depositAmount, lender.address, { value: depositAmount });

      // Withdraw
      await expectTokenChanges(
        () =>
          contracts.kubLending
            .connect(lender)
            .withdraw(depositAmount, lender.address),
        contracts.kkub,
        [lender.address, contracts.kubLending.address],
        [depositAmount, depositAmount],
        [Change.INC, Change.DEC]
      );
    });
  });

  describe("borrowKUB BKNext", () => {
    beforeEach(async () => {
      await contracts.kkub
        .connect(lender)
        .deposit({ value: depositAmount.mul(100) });

      await contracts.kkub
        .connect(lender)
        .approve(contracts.adminKAP20Router.address, constants.MaxUint256);

      await contracts.kubLending
        .connect(callHelper)
        .deposit(depositAmount, lender.address);
    });

    it("Should be able to deposit KKUB", async function () {
      const preBorrowerBal = await contracts.kkub.balanceOf(lender.address);
      const preContractBal = await contracts.kkub.balanceOf(
        contracts.kubLending.address
      );

      await contracts.kkub
        .connect(lender)
        .approve(contracts.adminKAP20Router.address, constants.MaxUint256);

      await contracts.kubLending
        .connect(callHelper)
        .deposit(depositAmount, lender.address);

      const postBorrowerBal = await contracts.kkub.balanceOf(lender.address);
      const postContractBal = await contracts.kkub.balanceOf(
        contracts.kubLending.address
      );

      expect(postBorrowerBal).to.eq(preBorrowerBal.sub(depositAmount));
      expect(postContractBal).to.eq(preContractBal.add(depositAmount));
    });

    it("Should correctly lends tokens", async function () {
      await enableBorrow(contracts.yesVault, borrower.address);

      const preBorrowerBal = await contracts.kkub.balanceOf(borrower.address);
      const preContractBal = await contracts.kkub.balanceOf(
        contracts.kubLending.address
      );

      await contracts.kubLending
        .connect(callHelper)
        .borrow(borrowAmount, borrower.address);

      const postBorrowerBal = await contracts.kkub.balanceOf(borrower.address);
      const postContractBal = await contracts.kkub.balanceOf(
        contracts.kubLending.address
      );

      expect(postBorrowerBal).to.gt(preBorrowerBal);
      expect(postContractBal).to.lt(preContractBal);
    });

    it("Should correctly operates withdraw", async function () {
      await contracts.kubLending
        .connect(callHelper)
        .deposit(borrowAmount, lender.address);

      const preBorrowerBal = await contracts.kkub.balanceOf(lender.address);
      const preContractBal = await contracts.kkub.balanceOf(
        contracts.kubLending.address
      );

      await contracts.kubLending
        .connect(callHelper)
        .withdrawUnderlying(borrowAmount, lender.address);

      const postBorrowerBal = await contracts.kkub.balanceOf(lender.address);
      const postContractBal = await contracts.kkub.balanceOf(
        contracts.kubLending.address
      );

      expect(postBorrowerBal).to.gt(preBorrowerBal);
      expect(postContractBal).to.lt(preContractBal);
    });

    it("Should correctly operates repayment", async function () {
      await enableBorrow(contracts.yesVault, borrower.address);

      await contracts.kubLending
        .connect(callHelper)
        .borrow(borrowAmount, borrower.address);

      const preBorrowerBal = await contracts.kkub.balanceOf(borrower.address);
      const preContractBal = await contracts.kkub.balanceOf(
        contracts.kubLending.address
      );

      await contracts.kkub
        .connect(borrower)
        .approve(contracts.adminKAP20Router.address, constants.MaxUint256);

      await contracts.kubLending
        .connect(callHelper)
        .repayBorrow(borrowAmount, borrower.address);

      const postBorrowerBal = await contracts.kkub.balanceOf(borrower.address);
      const postContractBal = await contracts.kkub.balanceOf(
        contracts.kubLending.address
      );

      expect(postBorrowerBal).to.lt(preBorrowerBal);
      expect(postContractBal).to.gt(preContractBal);
    });
  });
});
