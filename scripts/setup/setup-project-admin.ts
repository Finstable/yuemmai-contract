import hre, { ethers } from "hardhat";
import { AdminProject__factory, YESToken__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";

export const setupProjectAdmin = async (projectName: string) => {
  const [owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const adminProject = AdminProject__factory.connect(
    addressList["AdminProject"],
    owner
  );

  await adminProject
    .addAdmin(owner.address, projectName)
    .then((tx) => tx.wait());

  console.log(
    `Is admin ${owner.address}: `,
    await adminProject.isAdmin(owner.address, projectName)
  );
};
