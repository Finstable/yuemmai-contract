import hre, { ethers } from "hardhat";
import { YESAdmin__factory, YESController__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import { getSigners } from "../utils/getSigners";

export const setupYESAdmin = async () => {
  const [owner] = await getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const yesAdmin = YESAdmin__factory.connect(addressList["YESAdmin"], owner);

  await yesAdmin.addSuperAdmin(owner.address).then((tx) => tx.wait());
  console.log(`Set up ${owner.address} to be super admin`);

  await yesAdmin.addAdmin(owner.address).then((tx) => tx.wait());
  console.log(`Set up ${owner.address} to be admin`);
};
