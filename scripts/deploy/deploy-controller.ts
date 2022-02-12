import { formatEther } from "ethers/lib/utils";
import hre from "hardhat";
import { YESController__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import { getSigners } from "../utils/getSigners";

export const deployController = async () => {
  const [owner] = await getSigners();

  const YESController = (await hre.ethers.getContractFactory(
    "YESController"
  )) as YESController__factory;
  const yesController = await YESController.connect(owner).deploy(
    owner.address
  );
  await yesController.deployTransaction
    .wait()
    .then((res) => res.transactionHash);

  console.log("YES Controller: ", yesController.address);

  await addressUtils.saveAddresses(hre.network.name, {
    YESController: yesController.address,
  });
};
