import addressUtils from "../../utils/addressUtils";
import { deployController } from "../deploy/deploy-controller";
import hre, { ethers } from "hardhat";
import {
  YESVault__factory,
  KAP20Lending__factory,
  KUBLending__factory,
  YESController__factory,
  YESPriceOracle__factory,
} from "../../typechain";
import { setupController } from "../deploy/setup-controller";

async function main() {
  const [owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const controller = YESController__factory.connect(
    addressList["YESController"],
    owner
  );
  const oracle = YESPriceOracle__factory.connect(
    addressList["YESPriceOracle"],
    owner
  );

  console.log("Old oracle: ", await controller.oracle());

  await controller.setPriceOracle(oracle.address).then(tx => tx.wait());

  console.log("New oracle: ", await controller.oracle());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
