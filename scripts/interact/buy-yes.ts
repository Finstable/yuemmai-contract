import { parseEther } from "@ethersproject/units";
import { constants } from "ethers";
import { formatEther } from "ethers/lib/utils";
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

  const kusdt = KAP20__factory.connect(addressList["KUSDT"], owner);

  console.log(
    "Balance: ",
    await kusdt.balanceOf(owner.address).then((res) => formatEther(res))
  );

  await kusdt
    .approve(addressList["SwapRouter"], constants.MaxUint256)
    .then((tx) => tx.wait());

  const router = SwapRouter__factory.connect(addressList["SwapRouter"], owner);

  await router
    .swapExactTokensForTokens(
      parseEther("76277.23480496"),
      0,
      [addressList["KUSDT"], addressList["YES"]],
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
