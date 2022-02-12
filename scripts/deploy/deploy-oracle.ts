import hre from "hardhat";
import {
  SlidingWindowOracle__factory,
  YESPriceOracle__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import timeUtils from "../../utils/timeUtils";
import { getSigners } from "../utils/getSigners";

export const deployOracle = async () => {
  const [owner] = await getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const SlidingWindowOracle = (await hre.ethers.getContractFactory(
    "SlidingWindowOracle"
  )) as SlidingWindowOracle__factory;
  const YESPriceOracle = (await hre.ethers.getContractFactory(
    "YESPriceOracle"
  )) as YESPriceOracle__factory;

  const slidingWindowOracle = await SlidingWindowOracle.connect(owner).deploy(
    addressList["SwapFactory"],
    timeUtils.duration.minutes(10),
    2
  );
  await slidingWindowOracle.deployTransaction.wait();
  console.log("Deployed sliding window oracle: ", slidingWindowOracle.address);

  const yesPriceOracle = await YESPriceOracle.connect(owner).deploy(
    slidingWindowOracle.address,
    addressList["YES"],
    [addressList["KUSDT"]]
  );
  await yesPriceOracle.deployTransaction.wait();
  console.log("Deploy success: ", yesPriceOracle.address);

  await addressUtils.saveAddresses(hre.network.name, {
    YESPriceOracle: yesPriceOracle.address,
    SlidingWindowOracle: slidingWindowOracle.address,
  });
};
