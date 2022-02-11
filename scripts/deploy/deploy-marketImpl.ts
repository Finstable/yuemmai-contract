import hre from "hardhat";
import { MarketImpl__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import { getSigners } from "../utils/getSigners";

export const deployMarketImpl = async () => {
  const [owner] = await getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const MarketImpl = (await hre.ethers.getContractFactory(
    "MarketImpl"
  )) as MarketImpl__factory;

  const marketImpl = await MarketImpl.connect(owner).deploy();
  console.log("Deploy Market Impl success: ", marketImpl.address);

  await marketImpl.deployTransaction.wait();

  await addressUtils.saveAddresses(hre.network.name, {
    MarketImpl: marketImpl.address,
  });
};
