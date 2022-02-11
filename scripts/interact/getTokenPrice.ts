import { formatUnits } from "@ethersproject/units";
import { formatEther } from "ethers/lib/utils";
import hre, { ethers } from "hardhat";
import {
  YESPriceOracle__factory,
  YESVault,
  YESVault__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";

async function main() {
  const [owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const oracle = await YESPriceOracle__factory.connect(
    addressList["YESPriceOracle"],
    owner
  );

  console.log(
    "KUSDT: ",
    await oracle
      .getLatestPrice(addressList["KUSDT"])
      .then((res) => formatEther(res))
  );
  console.log(
    "KKUB: ",
    await oracle
      .getLatestPrice(addressList["KKUB"])
      .then((res) => formatEther(res))
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
