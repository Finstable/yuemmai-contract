import hre from "hardhat";
import addressUtils from "../../utils/addressUtils";
import { formatUnits } from "@ethersproject/units";
import {
  YESPriceOracleV1V2__factory,
  YESPriceOracle__factory,
} from "../../typechain";

async function main() {
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const [owner] = await hre.ethers.getSigners();

  const newOracle = YESPriceOracleV1V2__factory.connect(
    addressList["YESPriceOracleV1V2"],
    owner
  );

  const oldPriceOracle = YESPriceOracle__factory.connect(
    addressList["YESPriceOracle"],
    owner
  );

  const oldYesPrice = await oldPriceOracle.getYESPrice();
  const newYesPrice = await newOracle.getYESPrice();

  console.log(
    `Token: YES, oldPrice: ${formatUnits(
      oldYesPrice,
      18
    )}, newPrice: ${formatUnits(newYesPrice, 18)}`
  );

  const tokens = ["KUSDT", "KUSDC", "KKUB"];

  for (let i = 0; i < tokens.length; i++) {
    const oldPrice = await oldPriceOracle.getLatestPrice(
      addressList[tokens[i]]
    );
    const newPrice = await newOracle.getLatestPrice(addressList[tokens[i]]);
    console.log(
      `Token: ${tokens[i]}, oldPrice: ${formatUnits(
        oldPrice,
        18
      )}, newPrice: ${formatUnits(newPrice, 18)}`
    );
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
