import { formatEther, parseEther } from "@ethersproject/units";
import { ethers, network } from "hardhat";
import {
  KUBLending__factory,
  YESController__factory,
  YESToken__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";

async function main() {
  const [owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(network.name);

  const controller = YESController__factory.connect(
    addressList["YESController"],
    owner
  );

  console.log("Oracle: ", await controller.oracle());
  console.log("Markets: ", await controller.allMarkets());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
