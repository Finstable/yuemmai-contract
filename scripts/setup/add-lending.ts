import hre from "hardhat";
import { YESController__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import { getSigners } from "../utils/getSigners";

export const addLending = async () => {
  const [owner] = await getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const controller = await YESController__factory.connect(
    addressList["YESController"],
    owner
  );

  //   await controller
  //     .supportMarket(addressList["KUSDTLending"])
  //     .then((tx) => tx.wait());
  //   console.log("Add KUSDT to market");

  await controller
    .supportMarket(addressList["KUBLending"])
    .then((tx) => tx.wait());
  console.log("Add KUB to market");

  await controller
    .supportMarket(addressList["KUSDCLending"])
    .then((tx) => tx.wait());
  console.log("Add KUSDC to market");
};
