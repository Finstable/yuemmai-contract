import hre from "hardhat";
import addressUtils from "../../utils/addressUtils";
import { YESPriceOracleV1V3__factory } from "../../typechain";

export const deployYesPriceOracleV1V3 = async () => {
  const [owner] = await hre.ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const YESPriceOracleV1V3 = (await hre.ethers.getContractFactory(
    "YESPriceOracleV1V3"
  )) as YESPriceOracleV1V3__factory;

  const yesPriceOracleV1V3 = await YESPriceOracleV1V3.connect(owner).deploy(
    addressList["SlidingWindowOracle"],
    addressList["KUSDT"],
    addressList["YES"],
    [addressList["YUSDT"]],
    addressList["YESPriceFeed"]
  );

  await yesPriceOracleV1V3.deployTransaction.wait();
  console.log("Deployed YESPriceOracleV1V3 success");

  await addressUtils.saveAddresses(hre.network.name, {
    YESPriceOracleV1V3: yesPriceOracleV1V3.address,
  });
};
