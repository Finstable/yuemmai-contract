import { formatEther, parseEther } from "ethers/lib/utils";
import hre from "hardhat";
import { YESController__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import { getSigners } from "../utils/getSigners";

export const updateCollateralFactor = async () => {
  const [owner] = await getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const controller = await YESController__factory.connect(
    addressList["YESController"],
    owner
  );

  const collateralFactor = parseEther("0.5");

  await controller
    .setCollateralFactor(collateralFactor)
    .then((tx) => tx.wait());

  console.log(
    "Set collateral factor to: ",
    await controller.collateralFactorMantissa().then((res) => formatEther(res))
  );
};
