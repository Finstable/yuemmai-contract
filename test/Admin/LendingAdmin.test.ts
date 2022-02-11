import { parseEther, formatEther } from "@ethersproject/units";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { deployController, deployJumpRateModel } from "../shared/deployer";
import { Contracts, deployYESSystem } from "../shared/setup";

describe("LendingAdmin", () => {
  let contracts: Contracts;
  let signers: SignerWithAddress[];
  let admin: SignerWithAddress;

  beforeEach(async () => {
    contracts = await deployYESSystem();
    signers = await ethers.getSigners();
    admin = signers[0];
  });

  it("Test Admin set Controller ", async () => {
    const newController = await deployController(admin.address);
    await contracts.kusdtLending._setController(newController.address);
    const controllerAddress = await contracts.kusdtLending.controller();
    expect(controllerAddress).to.eq(newController.address);
  });

  it("Test Admin set InterestRateModel", async () => {
    const newInterestRateModel = await deployJumpRateModel();
    await contracts.kusdtLending._setInterestRateModel(
      newInterestRateModel.address
    );
    const interestRateModalAddr =
      await contracts.kusdtLending.interestRateModel();
    expect(interestRateModalAddr).to.eq(newInterestRateModel.address);
  });

  it("Test Admin set PlatformReserveFactor", async () => {
    const newPlatformReserveFactor = parseEther("0.2");
    await contracts.kusdtLending._setPlatformReserveFactor(
      newPlatformReserveFactor
    );
    const platformReserveFactor =
      await contracts.kusdtLending.platformReserveFactorMantissa();
    expect(formatEther(platformReserveFactor)).to.eq(
      formatEther(newPlatformReserveFactor)
    );
  });

  it("Test Admin set PoolReserveFactor", async () => {
    const newPoolReserveFactor = parseEther("0.2");
    await contracts.kusdtLending._setPoolReserveFactor(newPoolReserveFactor);
    const poolReserveFactor =
      await contracts.kusdtLending.poolReserveFactorMantissa();
    expect(formatEther(poolReserveFactor)).to.eq(
      formatEther(newPoolReserveFactor)
    );
  });
});
