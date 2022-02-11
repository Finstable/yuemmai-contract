import { parseEther } from "@ethersproject/units";
import hre, { ethers } from "hardhat";
import { YESAdmin__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import { getSigners } from "../utils/getSigners";

export const deployYESAdmin = async () => {
  const [owner] = await getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const adminChangeKey = "yuemmai-key";

  const YESAdmin = (await hre.ethers.getContractFactory(
    "YESAdmin"
  )) as YESAdmin__factory;
  const yesAdmin = await YESAdmin.connect(owner).deploy(
    owner.address,
    addressList["YuemmaiCallHelper"],
    ethers.utils.formatBytes32String(adminChangeKey)
  );
  await yesAdmin.deployTransaction.wait().then((res) => res.transactionHash);

  console.log("YES Admin: ", yesAdmin.address);

  await addressUtils.saveAddresses(hre.network.name, {
    YESAdmin: yesAdmin.address,
  });
};
