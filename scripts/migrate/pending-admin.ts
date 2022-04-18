import { formatEther, parseEther } from "ethers/lib/utils";
import hre from "hardhat";
import { KAP20Lending__factory, YESController__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import { getSigners } from "../utils/getSigners";

export const main = async () => {
  const [owner] = await getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const lending = await KAP20Lending__factory.connect(
    addressList["KUSDCLending"],
    owner
  );

  const timelock = addressList["Timelock"];

  await lending.setPendingSuperAdmin(timelock).then((tx) => tx.wait());

  console.log("Set pending admin to", await lending.pendingSuperAdmin());
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
