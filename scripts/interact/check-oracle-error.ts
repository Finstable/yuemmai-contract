import { parseEther } from "@ethersproject/units";
import hre, { ethers } from "hardhat";
import {
  DiamonPair__factory,
  SlidingWindowOracle__factory,
  TestDiamonFactory__factory,
  YESToken__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";

async function main() {
  const [owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const slidingWindowOracle = SlidingWindowOracle__factory.connect(
    addressList["SlidingWindowOracle"],
    owner
  );

  const factory = TestDiamonFactory__factory.connect(
    addressList["SwapFactory"],
    owner
  );

  const pairAddr = await factory.getPair(
    addressList["KKUB"],
    addressList["YES"]
  );

  const pair = DiamonPair__factory.connect(pairAddr, owner);

  const now = Math.floor(new Date().valueOf() / 1000);
  const index = await slidingWindowOracle.observationIndexOf(now);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
