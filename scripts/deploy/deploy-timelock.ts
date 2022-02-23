import hre from "hardhat";
import { Timelock__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import timeUtils from "../../utils/timeUtils";
import { getSigners } from "../utils/getSigners";

export const deployTimelock = async () => {
  const [owner] = await getSigners();

  const delay = timeUtils.duration.days(1);

  const Timelock = (await hre.ethers.getContractFactory(
    "Timelock"
  )) as Timelock__factory;

  const timelock = await Timelock.connect(owner).deploy(owner.address, delay);

  await timelock.deployTransaction.wait();
  console.log("Deploy Timelock success: ", timelock.address);

  await addressUtils.saveAddresses(hre.network.name, {
    Timelock: timelock.address,
  });
};
