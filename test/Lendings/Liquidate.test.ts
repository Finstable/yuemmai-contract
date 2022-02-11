import { parseEther } from "@ethersproject/units";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { constants } from "ethers";
import { formatEther } from "ethers/lib/utils";
import { ethers } from "hardhat";
import timeUtils from "../../utils/timeUtils";
import { Contracts, deployYESSystem, initialPool } from "../shared/setup";
import { enableBorrow } from "../shared/utils";

describe("Lendings - Liquidate", () => {
  let contracts: Contracts;

  let senders: SignerWithAddress[];

  let owner: SignerWithAddress;
  let lender: SignerWithAddress;
  let borrower: SignerWithAddress;
  let liquidator: SignerWithAddress;
  let callHelper: SignerWithAddress;

  const collateralFactor = 0.25;
  const yesInKUB = +initialPool.KUBYES[0] / +initialPool.KUBYES[1];
  const yesInKUSDT = +initialPool.KUSDTYES[0] / +initialPool.KUSDTYES[1];

  const depositAmount = parseEther("100");
  const kubBorrowAmount = parseEther((yesInKUB * collateralFactor).toString());
  const kusdtBorrowAmount = parseEther(
    (yesInKUSDT * collateralFactor).toString()
  );

  beforeEach(async () => {
    senders = await ethers.getSigners();
    contracts = await deployYESSystem();

    owner = senders[0];
    lender = senders[1];
    borrower = senders[2];
    liquidator = senders[3];
    callHelper = senders[4];
  });

  it("should be able to liquidate borrow KUB", async () => {
    await contracts.kubLending
      .connect(borrower)
      .deposit(depositAmount, borrower.address, { value: depositAmount });

    await enableBorrow(contracts.yesVault, borrower.address, "1");

    await contracts.kubLending
      .connect(borrower)
      .borrow(kubBorrowAmount, borrower.address);

    await contracts.kubLending.accrueInterest().then((tx) => tx.wait());
    await contracts.kubLending.accrueInterest().then((tx) => tx.wait());
    await contracts.kubLending.accrueInterest().then((tx) => tx.wait());

    const accountLiquidity1 = await contracts.controller.getAccountLiquidity(
      borrower.address
    );

    const deadline = timeUtils.now() + timeUtils.duration.hours(24);
    const input = parseEther("0.1");
    const minReward = 0;

    await contracts.kubLending
      .connect(liquidator)
      .liquidateBorrow(
        input,
        minReward,
        deadline,
        borrower.address,
        liquidator.address,
        { value: input }
      )
      .then((tx) => tx.wait());

    const accountLiquidity2 = await contracts.controller.getAccountLiquidity(
      borrower.address
    );

    expect(accountLiquidity2[1]).to.lt(accountLiquidity1[1]);
    expect(accountLiquidity2[3]).to.lt(accountLiquidity1[3]);
  });

  it("should be able to liquidate borrow token", async () => {
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

    await enableBorrow(contracts.yesVault, borrower.address, "1");

    await contracts.kusdtLending
      .connect(borrower)
      .borrow(kusdtBorrowAmount, borrower.address)
      .then((tx) => tx.wait());

    await contracts.kusdtLending.accrueInterest().then((tx) => tx.wait());
    await contracts.kusdtLending.accrueInterest().then((tx) => tx.wait());
    await contracts.kusdtLending.accrueInterest().then((tx) => tx.wait());
    await contracts.kusdtLending.accrueInterest().then((tx) => tx.wait());

    const accountLiquidity1 = await contracts.controller.getAccountLiquidity(
      borrower.address
    );

    const deadline = timeUtils.now() + timeUtils.duration.hours(24);
    const input = parseEther("0.1");
    const minReward = 0;

    await contracts.kusdt
      .connect(liquidator)
      .approve(contracts.kusdtLending.address, constants.MaxUint256);

    await contracts.kusdtLending
      .connect(liquidator)
      .liquidateBorrow(
        input,
        minReward,
        deadline,
        borrower.address,
        liquidator.address
      )
      .then((tx) => tx.wait());

    const accountLiquidity2 = await contracts.controller.getAccountLiquidity(
      borrower.address
    );

    expect(accountLiquidity2[1]).to.lt(accountLiquidity1[1]);
    expect(accountLiquidity2[3]).to.lt(accountLiquidity1[3]);
  });

  it("BKNext should be able to liquidate borrow KUB", async () => {
    // Wrap KUB
    await contracts.kkub.connect(lender).deposit({ value: depositAmount });
    // Lender approve tokens to lending contract
    await contracts.kkub
      .connect(callHelper)
      .approve(contracts.adminKAP20Router.address, depositAmount)
      .then((tx) => tx.wait());
    // Lender deposits tokens
    await contracts.kubLending
      .connect(callHelper)
      .deposit(depositAmount, lender.address)
      .then((tx) => tx.wait());

    await enableBorrow(contracts.yesVault, borrower.address, "1");

    await contracts.kubLending
      .connect(callHelper)
      .borrow(kubBorrowAmount, borrower.address)
      .then((tx) => tx.wait());

    await contracts.kubLending.accrueInterest().then((tx) => tx.wait());
    await contracts.kubLending.accrueInterest().then((tx) => tx.wait());
    await contracts.kubLending.accrueInterest().then((tx) => tx.wait());

    const accountLiquidity1 = await contracts.controller.getAccountLiquidity(
      borrower.address
    );

    const deadline = timeUtils.now() + timeUtils.duration.hours(24);
    const input = parseEther("0");
    const minReward = 0;

    await contracts.kkub.connect(liquidator).deposit({ value: input });

    await contracts.kubLending
      .connect(callHelper)
      .liquidateBorrow(
        input,
        minReward,
        deadline,
        borrower.address,
        liquidator.address
      )
      .then((tx) => tx.wait());

    const accountLiquidity2 = await contracts.controller.getAccountLiquidity(
      borrower.address
    );

    expect(accountLiquidity2[1]).to.lt(accountLiquidity1[1]);
    expect(accountLiquidity2[3]).to.lt(accountLiquidity1[3]);
  });

  it("BKNext should be able to liquidate borrow token", async () => {
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

    await enableBorrow(contracts.yesVault, borrower.address, "1");

    await contracts.kusdtLending
      .connect(borrower)
      .borrow(kusdtBorrowAmount, borrower.address)
      .then((tx) => tx.wait());

    await contracts.kusdtLending.accrueInterest().then((tx) => tx.wait());
    await contracts.kusdtLending.accrueInterest().then((tx) => tx.wait());
    await contracts.kusdtLending.accrueInterest().then((tx) => tx.wait());

    const accountLiquidity1 = await contracts.controller.getAccountLiquidity(
      borrower.address
    );

    const deadline = timeUtils.now() + timeUtils.duration.hours(24);
    const input = parseEther("0.1");
    const minReward = 0;

    await contracts.kusdtLending
      .connect(callHelper)
      .liquidateBorrow(
        input,
        minReward,
        deadline,
        borrower.address,
        liquidator.address
      )
      .then((tx) => tx.wait());

    const accountLiquidity2 = await contracts.controller.getAccountLiquidity(
      borrower.address
    );

    expect(accountLiquidity2[1]).to.lt(accountLiquidity1[1]);
    expect(accountLiquidity2[3]).to.lt(accountLiquidity1[3]);
  });
});
