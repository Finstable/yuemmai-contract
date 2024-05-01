import hre from "hardhat";
import addressUtils from "../../utils/addressUtils";
import { formatUnits } from "@ethersproject/units";
import {
  YESPriceOracleV1V2__factory,
  YESPriceOracle__factory,
  YESPriceOracleV1V3__factory,
  YESPriceOracleV1V4__factory
} from "../../typechain";

async function main() {
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const [owner] = await hre.ethers.getSigners();

  const oracleV4 = YESPriceOracleV1V4__factory.connect(
    addressList["YESPriceOracleV1V4"],
    owner
  );

  const oracleV3 = YESPriceOracleV1V3__factory.connect(
    addressList["YESPriceOracleV1V3"],
    owner
  );

  const oracleV2 = YESPriceOracleV1V2__factory.connect(
    addressList["YESPriceOracleV1V2"],
    owner
  );

  const oracleV1 = YESPriceOracle__factory.connect(
    addressList["YESPriceOracle"],
    owner
  );

  const v4YesPrice = await oracleV3.getYESPrice();
  // const v3YesPrice = await oracleV3.getYESPrice();
  // const v2YesPrice = await oracleV2.getYESPrice();
  // const v1YesPrice = await oracleV1.getYESPrice();

  console.log(`v4Price: ${formatUnits(v4YesPrice, 18)}`);
  // console.log(`v3Price: ${formatUnits(v3YesPrice, 18)}`);
  // console.log(`v2Price: ${formatUnits(v2YesPrice, 18)}`);
  // console.log(`v1Price: ${formatUnits(v1YesPrice, 18)}`);

  const tokens = ["KUSDT", "KUSDC", "KKUB"];

  for (let i = 0; i < tokens.length; i++) {
    // const v1 = await oracleV1.getLatestPrice(addressList[tokens[i]]);
    // const v2 = await oracleV2.getLatestPrice(addressList[tokens[i]]);
    // const v3 = await oracleV3.getLatestPrice(addressList[tokens[i]]);
    const v4 = await oracleV4.getLatestPrice(addressList[tokens[i]]);
    // console.log(`v1Price:${tokens[i]}: ${formatUnits(v1, 18)}`);
    // console.log(`v2Price:${tokens[i]}: ${formatUnits(v2, 18)}`);
    // console.log(`v3Price:${tokens[i]}: ${formatUnits(v3, 18)}`);
    console.log(`v4Price:${tokens[i]}: ${formatUnits(v4, 18)}`);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
