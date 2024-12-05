import hre, { ethers } from "hardhat";
import {
  SlidingWindowOracle__factory,
  YESPriceOracle__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import { getSigners } from "../utils/getSigners";


// The script to manually update price when the service is down.
export const updatePrice = async () => {
  const [owner] = await getSigners();

  const addressList = await addressUtils.getAddressList(hre.network.name);

  const slidingWindowOracle = SlidingWindowOracle__factory.connect(
    addressList["SlidingWindowOracle"],
    owner
  );

  await slidingWindowOracle
    .update(addressList["KUSDT"], addressList["YES"])
    .then((tx) => tx.wait());
  console.log("Updated KUSDT-YES price");

  await slidingWindowOracle
    .update(addressList["YUSDT"], addressList["YES"])
    .then((tx) => tx.wait());
  console.log("Updated YUSDT-YES price");

};

updatePrice()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
