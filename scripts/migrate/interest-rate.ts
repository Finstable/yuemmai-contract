import { formatEther, parseEther } from "ethers/lib/utils";
import hre from "hardhat";
import { KAP20Lending__factory, YESController__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import { getSigners } from "../utils/getSigners";

export const main = async () => {
  const [owner] = await getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const lending = await KAP20Lending__factory.connect(
    addressList["KUBLending"],
    owner
  );

  const jumpRateModel = addressList["InterestRateModel"];

  await lending._setInterestRateModel(jumpRateModel).then((tx) => tx.wait());

  console.log("Set interest rat model to", await lending.interestRateModel());
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
