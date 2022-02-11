import hre from "hardhat";
import { KAP20Lending__factory, KUBLending__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import { getSigners } from "../utils/getSigners";

const projectName = "yuemmai";

const setupLending = async (token: string) => {
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const [owner] = await getSigners();
  console.log(`Setup ${token}`);

  const lending =
    token === "KUB"
      ? KUBLending__factory.connect(addressList["KUBLending"], owner)
      : KAP20Lending__factory.connect(addressList[`${token}Lending`], owner);

  // const adminProject = AdminProject__factory.connect(
  //   addressList["AdminProject"],
  //   owner
  // );

  // WHITELIST: KAP20Router
  // await adminProject.addSuperAdmin(lending.address, projectName);
};

export const setupLendings = async () => {
  await setupLending("KUB");
  await setupLending("KUSDT");
};
