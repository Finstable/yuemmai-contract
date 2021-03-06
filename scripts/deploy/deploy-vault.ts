import hre, { ethers } from "hardhat";
import { YESVault__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import time from "../../utils/timeUtils";
import { getSigners } from "../utils/getSigners";

export const deployVault = async () => {
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const [owner] = await getSigners();

  const YESVault = (await hre.ethers.getContractFactory(
    "YESVault"
  )) as YESVault__factory;

  // const releaseTime = await time.latest() + time.duration.years(1);
  const releaseTime = Math.floor(new Date("2022-11-14 00:00").valueOf() / 1000);

  const admin = owner.address;
  const superAdmin = owner.address;

  const yesVault = await YESVault.connect(owner).deploy(
    addressList["YESController"],
    addressList["YES"],
    addressList["MarketImpl"],
    addressList["SwapRouter"],
    releaseTime,
    admin,
    superAdmin,
    addressList["Committee"],
    addressList["YuemmaiCallHelper"],
    addressList["TransferRouter"]
  );

  await yesVault.deployTransaction.wait();
  console.log("Deploy YES Vault success: ", yesVault.address);

  await addressUtils.saveAddresses(hre.network.name, {
    YESVault: yesVault.address,
  });
};
