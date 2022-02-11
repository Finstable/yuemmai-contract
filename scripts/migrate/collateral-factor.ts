import addressUtils from "../../utils/addressUtils";
import { deployController } from "../deploy/deploy-controller";
import hre, { ethers } from "hardhat";
import {
  YESVault__factory,
  KAP20Lending__factory,
  KUBLending__factory,
  YESController__factory,
} from "../../typechain";
import { setupController } from "../deploy/setup-controller";
import { formatEther, parseEther } from "ethers/lib/utils";

async function main() {
  const [owner] = await ethers.getSigners();

  const addressList = await addressUtils.getAddressList(hre.network.name);

  const controller = YESController__factory.connect(
    addressList["YESController"],
    owner
  );

  const collateralFactor = parseEther("0.75");

  await controller
    ._setCollateralFactor(collateralFactor)
    .then((tx) => tx.wait());

  console.log(
    "Set collateral factor to: ",
    await controller.collateralFactorMantissa().then((res) => formatEther(res))
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
