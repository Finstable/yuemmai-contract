import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { formatEther, parseEther } from "ethers/lib/utils";
import { ethers } from "hardhat";
import { expect } from "chai";
import { YESToken } from "../../typechain";
import { deployKAP20Lending } from "../shared/deployer";
import { Contracts, deployYESSystem } from "../shared/setup";

describe("Controller", () => {
  let contracts: Contracts;
  let borrower: SignerWithAddress;
  let yes: YESToken;
  let signers: SignerWithAddress[];
  let senders: SignerWithAddress[];
  let customer: SignerWithAddress;

  beforeEach(async () => {
    signers = await ethers.getSigners();
    customer = signers[1];

    senders = await ethers.getSigners();
    contracts = await deployYESSystem();
    borrower = senders[2];
  });

  it("Test supportMarket", async () => {
    const newAdmin = signers[0].address;
    const lContractAddress = await deployKAP20Lending(
      contracts.kusdt.address,
      contracts.controller.address,
      contracts.interest.address,
      "KUSDT Lending",
      "L-KUSDT",
      18,
      "1",
      contracts.beneficiary,
      contracts.poolReserve,
      contracts.superAdmin,
      contracts.callHelper,
      contracts.committee,
      contracts.adminProjectRouter.address,
      contracts.adminKAP20Router.address,
      contracts.kyc.address,
      1
    );
    await contracts.controller.supportMarket(lContractAddress.address);
    const adminAddress = await contracts.yesVault.admin();
    expect(adminAddress).to.eq(newAdmin);
  });

  it("Test size false setSeizePaused", async () => {
    const size = false;
    const newAdmin = signers[0].address;
    await contracts.controller.setSeizePaused(size);
    const adminAddress = await contracts.yesVault.admin();
    expect(adminAddress).to.eq(newAdmin);
  });

  it("Test size true setSeizePaused", async () => {
    const size = true;
    const newAdmin = signers[0].address;
    await contracts.controller.setSeizePaused(size);
    const adminAddress = await contracts.yesVault.admin();
    expect(adminAddress).to.eq(newAdmin);
  });

  it("Test size true setDepositPaused", async () => {
    const size = true;
    const newAdmin = signers[0].address;
    await contracts.controller.setDepositPaused(
      contracts.kusdtLending.address,
      size
    );
    const adminAddress = await contracts.yesVault.admin();
    expect(adminAddress).to.eq(newAdmin);
  });

  it("Test size false setDepositPaused", async () => {
    const size = false;
    const newAdmin = signers[0].address;
    await contracts.controller.setDepositPaused(
      contracts.kusdtLending.address,
      size
    );
    const adminAddress = await contracts.yesVault.admin();
    expect(adminAddress).to.eq(newAdmin);
  });

  it("Test  size true setBorrowPaused", async () => {
    const size = false;
    const newAdmin = signers[0].address;
    await contracts.controller.setBorrowPaused(
      contracts.kusdtLending.address,
      size
    );
    const adminAddress = await contracts.yesVault.admin();
    expect(adminAddress).to.eq(newAdmin);
  });

  it("Test size false setBorrowPaused", async () => {
    const size = false;
    const newAdmin = signers[0].address;
    await contracts.controller.setBorrowPaused(
      contracts.kusdtLending.address,
      size
    );
    const adminAddress = await contracts.yesVault.admin();
    expect(adminAddress).to.eq(newAdmin);
  });

  it("Test setPriceOracle", async () => {
    const newAdmin = signers[0].address;
    await contracts.controller.setPriceOracle(newAdmin);
    const adminAddress = await contracts.yesVault.admin();
    expect(adminAddress).to.eq(newAdmin);
  });

  it("Test setYESVault", async () => {
    const newAdmin = signers[0].address;
    await contracts.controller.setYESVault(newAdmin);
    const adminAddress = await contracts.yesVault.admin();
    expect(adminAddress).to.eq(newAdmin);
  });

  it("Test setCollateralFactor", async () => {
    const value = parseEther("0.1");
    await contracts.controller.setCollateralFactor(value);
    const collateralFactor =
      await contracts.controller.collateralFactorMantissa();
    expect(formatEther(value)).to.eq(formatEther(collateralFactor));
  });

  it("Test setLiquidationIncentive", async () => {
    const value = parseEther("0.25");
    await contracts.controller.setLiquidationIncentive(value);
    const collateralFactor =
      await contracts.controller.collateralFactorMantissa();
    expect(formatEther(value)).to.eq(formatEther(collateralFactor));
  });
});
