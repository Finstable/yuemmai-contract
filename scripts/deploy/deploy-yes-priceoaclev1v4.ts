import hre from "hardhat";
import addressUtils from "../../utils/addressUtils";
import { YESPriceOracleV1V4__factory } from "../../typechain";

export const deployYesPriceOracleV1V4 = async () => {
  const [owner] = await hre.ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const YESPriceOracleV1V4 = (await hre.ethers.getContractFactory(
    "YESPriceOracleV1V4"
  )) as YESPriceOracleV1V4__factory;

  const yesPriceOracleV1V4 = await YESPriceOracleV1V4.connect(owner).deploy(
    addressList["SlidingWindowOracle"],
    addressList['BKCOracleConsumer'],
    addressList["KUSDT"],
    addressList["YES"],
    [addressList["YUSDT"]],
  );

  await yesPriceOracleV1V4.deployTransaction.wait();
  console.log("Deployed YESPriceOracleV1V4 success");

  await addressUtils.saveAddresses(hre.network.name, {
    YESPriceOracleV1V4: yesPriceOracleV1V4.address,
  });

  const tokens = [addressList["KKUB"], addressList["KUSDC"]];
  const aggregators = ["0x775eeFF3f80f110C2f7ac9127041915489c275f4", "0xB36801C9BCeF88dd72FE17689C18179a97941069"];

  console.log("Setting aggregators...");
  await yesPriceOracleV1V4.setAggregators(tokens, aggregators);
  console.log("Set aggregators successfully");
};