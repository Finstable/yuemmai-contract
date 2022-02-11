import hre, { ethers } from "hardhat";
import {
  SlidingWindowOracle__factory,
  YESPriceOracle__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import { getSigners } from "../utils/getSigners";

export const setupPriceOracle = async () => {
  const [owner] = await getSigners();

  const addressList = await addressUtils.getAddressList(hre.network.name);

  const slidingWindowOracle = SlidingWindowOracle__factory.connect(
    addressList["SlidingWindowOracle"],
    owner
  );

  await slidingWindowOracle
    .update(addressList["KKUB"], addressList["YES"])
    .then((tx) => tx.wait());
  console.log("Updated KKUB-YES price");

  await slidingWindowOracle
    .update(addressList["KUSDT"], addressList["YES"])
    .then((tx) => tx.wait());
  console.log("Updated KUSDT-YES price");

  // await slidingWindowOracle
  //   .update(addressList["KUSDC"], addressList["YES"])
  //   .then((tx) => tx.wait());
  // console.log("Updated KUSDC-YES price");
};
