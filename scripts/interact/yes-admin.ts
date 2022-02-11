import hre, { ethers } from "hardhat";
import {
  SlidingWindowOracle__factory,
  YESAdmin__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";

async function main() {
  const [owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const yesAdmin = YESAdmin__factory.connect(addressList["YESAdmin"], owner);

  console.log(
    "Is callhelper: ",
    await yesAdmin.isCallHelper(addressList["YuemmaiCallHelper"])
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
