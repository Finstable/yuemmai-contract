import { parseEther } from "@ethersproject/units";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { deployController, deployMarketImpl } from "../shared/deployer";
import { Contracts, deployYESSystem } from "../shared/setup";

describe("YesVaultAdmin", () => {
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
    await contracts.yesVault.setController(newController.address);
    const controllerAddress = await contracts.yesVault.controller();
    expect(controllerAddress).to.eq(newController.address);
  });

  it("Test Admin set Market Impl", async () => {
    const newMarketImpl = await deployMarketImpl();
    await contracts.yesVault.setMarketImpl(newMarketImpl.address);
    const marketImplAddress = await contracts.yesVault.marketImpl();
    expect(marketImplAddress).to.eq(newMarketImpl.address);
  });

  it("Test Admin set Market", async () => {
    const newMarket = signers[1].address;
    await contracts.yesVault.setMarket(newMarket);
    const marketAddress = await contracts.yesVault.market();
    expect(marketAddress).to.eq(newMarket);
  });

  it("Test Admin set Admin", async () => {
    const newAdmin = signers[1].address;
    await contracts.yesVault.setAdmin(newAdmin);
    const adminAddress = await contracts.yesVault.admin();
    expect(adminAddress).to.eq(newAdmin);
  });
});
