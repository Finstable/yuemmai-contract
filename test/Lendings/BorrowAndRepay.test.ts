import { parseEther } from "@ethersproject/units";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { TokenError, TokenFailureInfo } from "../shared/error";
import { Contracts, deployYESSystem } from "../shared/setup";
import { Change, enableBorrow, expectTokenChanges } from "../shared/utils";

describe("Lending - BorrowAndRepay", () => {
  let contracts: Contracts;
  let senders: SignerWithAddress[];

  let lender: SignerWithAddress;
  let borrower: SignerWithAddress;
  let callHelper: SignerWithAddress;
  let bkNextUser: string;

  const depositAmount = parseEther("100");
  const borrowAmount = parseEther("10");

  beforeEach(async () => {
    senders = await ethers.getSigners();
    contracts = await deployYESSystem();

    lender = senders[1];
    borrower = senders[2];
    callHelper = senders[4];

    bkNextUser = lender.address;
  });

  describe("borrow", () => {
    it("fails if protocol has less than borrowAmount of underlying", async () => {
      // Increase borrower's collateral balance and borrow limit
      await enableBorrow(contracts.yesVault, borrower.address);

      // Expect borrowing to fail due to insufficient liquidity
      expect(
        await contracts.kusdtLending
          .connect(borrower)
          .borrow(borrowAmount, borrower.address)
      )
        .to.emit(contracts.kusdtLending, "Failure")
        .withArgs(
          TokenError.TOKEN_INSUFFICIENT_CASH,
          TokenFailureInfo.BORROW_CASH_NOT_AVAILABLE,
          0
        );
    });

    it("Should correctly lends/borrows tokens", async function () {
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

      // Expect borrower's tokens increase and contract's tokens decrease
      await expectTokenChanges(
        () =>
          contracts.kusdtLending
            .connect(borrower)
            .borrow(borrowAmount, borrower.address),
        contracts.kusdt,
        [borrower.address, contracts.kusdtLending.address],
        [borrowAmount, borrowAmount],
        [Change.INC, Change.DEC]
      );
    });
  });

  describe("repayBorrow", () => {
    it("Should correctly operates repayment", async function () {
      // Lender approves tokens to the contract
      await contracts.kusdt
        .connect(lender)
        .approve(contracts.kusdtLending.address, depositAmount)
        .then((tx) => tx.wait());
      // Lender deposits tokens
      await contracts.kusdtLending
        .connect(lender)
        .deposit(depositAmount, lender.address)
        .then((tx) => tx.wait());

      // Increase borrower collateral value and borrow limit
      await enableBorrow(contracts.yesVault, borrower.address);

      // Borrower borrows tokens
      await contracts.kusdtLending
        .connect(borrower)
        .borrow(borrowAmount, borrower.address);

      // Borrower approve tokens to the contract
      await contracts.kusdt
        .connect(borrower)
        .approve(contracts.kusdtLending.address, borrowAmount);

      // Expect borrower tokens to decrease and contract tokens to increase
      await expectTokenChanges(
        () =>
          contracts.kusdtLending
            .connect(borrower)
            .repayBorrow(borrowAmount, borrower.address),
        contracts.kusdt,
        [borrower.address, contracts.kusdtLending.address],
        [borrowAmount, borrowAmount],
        [Change.DEC, Change.INC]
      );
    });
  });

  describe("BK next", () => {
    beforeEach(async () => {
      await contracts.kusdtLending
        .connect(callHelper)
        .deposit(depositAmount, bkNextUser)
        .then((tx) => tx.wait());
    });

    it("Should correctly lends/borrows tokens", async function () {
      // Increase the collateral value and borrow limit of bkNextUser
      await enableBorrow(contracts.yesVault, bkNextUser);

      // Expect bkNextUser tokens to increase and contract tokens to decrease
      await expectTokenChanges(
        () =>
          contracts.kusdtLending
            .connect(callHelper)
            .borrow(borrowAmount, bkNextUser),
        contracts.kusdt,
        [bkNextUser, contracts.kusdtLending.address],
        [borrowAmount, borrowAmount],
        [Change.INC, Change.DEC]
      );
    });

    it("Should correctly operates withdraw", async function () {
      // Expect bkNextUser tokens to increase and contract tokens to decrease
      await expectTokenChanges(
        () =>
          contracts.kusdtLending
            .connect(callHelper)
            .withdraw(depositAmount, bkNextUser),
        contracts.kusdt,
        [bkNextUser, contracts.kusdtLending.address],
        [depositAmount, depositAmount],
        [Change.INC, Change.DEC]
      );
    });

    it("Should correctly operates repayment", async function () {
      // Increase the collateral value and borrow limit of bkNextUser
      await enableBorrow(contracts.yesVault, bkNextUser);

      // Callhelper calls borrow for bkNextUser
      await contracts.kusdtLending
        .connect(callHelper)
        .borrow(borrowAmount, bkNextUser);

      // Expect bkNextUser tokens to decrease and contract tokens to increase
      await expectTokenChanges(
        () =>
          contracts.kusdtLending
            .connect(callHelper)
            .repayBorrow(borrowAmount, bkNextUser),
        contracts.kusdt,
        [bkNextUser, contracts.kusdtLending.address],
        [borrowAmount, borrowAmount],
        [Change.DEC, Change.INC]
      );
    });
  });
});
