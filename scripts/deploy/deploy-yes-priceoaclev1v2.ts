import hre from "hardhat";
import addressUtils from "../../utils/addressUtils";
import { YESPriceOracleV1V2__factory } from "../../typechain";

export const deployYesPriceOracleV1V2 = async () => {
  const [owner] = await hre.ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const YESPriceOracleV1V2 = (await hre.ethers.getContractFactory(
    "YESPriceOracleV1V2"
  )) as YESPriceOracleV1V2__factory;

  const yesPriceOracleV1V2 = await YESPriceOracleV1V2.connect(owner).deploy(
    addressList["SlidingWindowOracle"],
    addressList["YES"],
    [addressList["KUSDT"]],
    addressList["YESPriceFeed"]
  );

  await yesPriceOracleV1V2.deployTransaction.wait();
  console.log("Deployed YESPriceOracleV1V2 success");

  await addressUtils.saveAddresses(hre.network.name, {
    YESPriceOracleV1V2: yesPriceOracleV1V2.address,
  });
};
