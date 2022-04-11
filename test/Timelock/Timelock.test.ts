import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { parseEther } from "ethers/lib/utils";
import { ethers } from "hardhat";
import timeUtils from "../../utils/timeUtils";
import { Contracts, deployYESSystem } from "../shared/setup";

describe("Timelock", () => {
  let contracts: Contracts;
  let signers: SignerWithAddress[];
  let admin: SignerWithAddress;

  beforeEach(async () => {
    contracts = await deployYESSystem();
    signers = await ethers.getSigners();
    admin = signers[0];
  });

  it("Test set a protocol value with timelock ", async () => {
    await contracts.controller.setPendingSuperAdmin(contracts.timelock.address);

    const encodedData1 =
      contracts.controller.interface.encodeFunctionData("acceptSuperAdmin");

    const newCollateralFactor = parseEther("0.75").toString();

    const encodedData2 = contracts.controller.interface.encodeFunctionData(
      "setCollateralFactor",
      [newCollateralFactor]
    );

    const eta =
      timeUtils.now() +
      timeUtils.duration.days(1) +
      timeUtils.duration.hours(1);

    await contracts.timelock.queueTransaction(
      contracts.controller.address,
      0,
      "",
      encodedData1,
      eta
    );

    await contracts.timelock.queueTransaction(
      contracts.controller.address,
      0,
      "",
      encodedData2,
      eta
    );

    await timeUtils.increase(
      timeUtils.duration.days(1) + timeUtils.duration.hours(2)
    );

    await contracts.timelock
      .executeTransaction(
        contracts.controller.address,
        0,
        "",
        encodedData1,
        eta
      )
      .then((tx) => tx.wait());

    await contracts.timelock
      .executeTransaction(
        contracts.controller.address,
        0,
        "",
        encodedData2,
        eta
      )
      .then((tx) => tx.wait());

    expect(await contracts.controller.superAdmin()).to.eq(
      contracts.timelock.address
    );

    expect(await contracts.controller.collateralFactorMantissa()).to.eq(
      newCollateralFactor
    );
  });
});
