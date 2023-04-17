import hre from "hardhat";
import { YESController__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import { getSigners } from "../utils/getSigners";

export const setupController = async () => {
  const [owner] = await getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const controller = await YESController__factory.connect(
    addressList["YESController"],
    owner
  );

  await controller
    .setPriceOracle(addressList["YESPriceOracleV1V2"])
    .then((tx) => tx.wait());
  console.log(
    "Controller connects price oracle at: ",
    await controller.oracle()
  );

  // await controller.setYESVault(addressList["YESVault"]).then((tx) => tx.wait());
  // console.log("Set YES vault to controller ", await controller.yesVault());

  // await controller
  //   .supportMarket(addressList["KUBLending"])
  //   .then((tx) => tx.wait());
  // console.log("Add KUB to market");

  // await controller
  //   .supportMarket(addressList["KUSDTLending"])
  //   .then((tx) => tx.wait());
  // console.log("Add KUSDT to market");

  // await controller
  //   .supportMarket(addressList["KUSDCLending"])
  //   .then((tx) => tx.wait());
  // console.log("Add KUSDC to market");
};
