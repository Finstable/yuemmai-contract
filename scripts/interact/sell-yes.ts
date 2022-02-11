import { parseEther } from "@ethersproject/units";
import { constants } from "ethers";
import hre, { ethers } from "hardhat";
import {
  AdminProject__factory,
  KAP20__factory,
  SwapRouter__factory,
  YESToken__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import timeUtils from "../../utils/timeUtils";

async function main() {
  const [owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  console.log("address: ", owner.address);

  const router = SwapRouter__factory.connect(addressList["SwapRouter"], owner);

  const yes = KAP20__factory.connect(addressList["YES"], owner);

  await yes
    .approve(router.address, constants.MaxUint256)
    .then((tx) => tx.wait());

  await router
    .swapExactTokensForTokens(
      parseEther("105445.533"),
      0,
      [addressList["YES"], addressList["KUSDT"]],
      owner.address,
      timeUtils.now() + timeUtils.duration.minutes(20)
    )
    .then((tx) => tx.wait());

  console.log("Trade success");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
