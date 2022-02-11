import { parseEther } from "@ethersproject/units";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Contracts, deployYESSystem } from "../shared/setup";

describe("Controller", () => {
  let contracts: Contracts;
  let signers: SignerWithAddress[];
  let customer: SignerWithAddress;

  const getAccountLiquidity = async (address: string) => {
    const result = await contracts.controller.getAccountLiquidity(address);
    return {
      err: result[0],
      collateralValue: result[1],
      borrowLimit: result[2],
      borrowValue: result[3],
    };
  };

  beforeEach(async () => {
    contracts = await deployYESSystem();

    await contracts.slidingWindowOracle.update(
      contracts.kusdt.address,
      contracts.yes.address
    );

    signers = await ethers.getSigners();
    customer = signers[1];
  });

  it("Should correctly provide customer's account liquidity", async () => {
    const borrowLimit = parseEther("1000");
    const releaseAmount = parseEther("100");

    await contracts.yesVault.setBorrowLimit(customer.address, borrowLimit);
    await contracts.yesVault.airdrop(customer.address, releaseAmount);

    const yesPrice = await contracts.yesPriceOracle.getYESPrice();

    const result = await getAccountLiquidity(customer.address);
    const collateralFactor = await contracts.controller.collateralFactorMantissa();
    
    expect(result.borrowLimit).to.eq(
      borrowLimit.mul(yesPrice).div(parseEther("1"))
    );
    expect(result.collateralValue).to.eq(
      releaseAmount.mul(collateralFactor).div(parseEther("1"))
    );
  });
});
