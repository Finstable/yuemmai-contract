import hre, { ethers } from "hardhat";
import {
  AdminProject__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";

const projectName = "yuemmai";

export const setupCallHelper = async () => {
  const [owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const adminProject = AdminProject__factory.connect(
    addressList["AdminProject"],
    owner
  );

  const helper = addressList["YuemmaiCallHelper"];

  await adminProject.addSuperAdmin(helper, projectName).then(tx => tx.wait());

  console.log(
    "Call helper is superadmin: ",
    await adminProject.isSuperAdmin(helper, projectName)
  );
};
