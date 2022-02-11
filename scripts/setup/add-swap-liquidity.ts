import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { constants } from "ethers";
import { formatEther } from "ethers/lib/utils";
import hre from "hardhat";
import {
  YESToken__factory,
  YESToken,
  KAP20__factory,
  KAP20,
  TestDiamonFactory__factory,
  TestDiamonRouter,
  TestDiamonRouter__factory,
  TestKKUB__factory,
  TestKUSDT,
  TestKUSDT__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import timeUtils from "../../utils/timeUtils";
import { getSigners } from "../utils/getSigners";

// Public sale YES = 1,200,000 YES. Split into 5 parts, 240,000 per part
// Alpha test: Public sale = 40,000,000. split  into 4 parts, 10,000,000 YES per part

const poolReserves = {
  KUBYES: [
    hre.ethers.utils.parseEther("10"), // 1 KUB = 12.93 USD
    hre.ethers.utils.parseEther("161.5"), // 1 YES = 26.74 THB = 0.8 USD
  ],
  KUSDTYES: [
    hre.ethers.utils.parseEther("1000000"), // 1 KUSDT = 33.43 THB = 1 USD
    hre.ethers.utils.parseEther("1250000"), // 1 YES = 26.74 THB = 0.8 USD
  ],
};

const addLiquidity = async (
  signer: SignerWithAddress,
  token: KAP20 | TestKUSDT,
  yesToken: YESToken,
  swapRouter: TestDiamonRouter,
  key: string
) => {
  await token
    .connect(signer)
    .approve(swapRouter.address, hre.ethers.constants.MaxUint256)
    .then((tx) => tx.wait());
  console.log(`${key}: Approve to Swap router success`);

  const pairToken = key.replace("YES", "");

  console.log(
    "Provide: ",
    +formatEther(poolReserves[key][0]) + " " + pairToken
  );
  console.log("Provide: ", +formatEther(poolReserves[key][1]) + " " + "YES");

  console.log(
    "Balance: ",
    await token.balanceOf(signer.address).then((res) => formatEther(res)),
    pairToken
  );
  console.log(
    "Balance: ",
    await yesToken.balanceOf(signer.address).then((res) => formatEther(res)),
    "YES"
  );

  console.log("Token addr: ", token.address);

  await swapRouter
    .connect(signer)
    .addLiquidity(
      token.address,
      yesToken.address,
      poolReserves[key][0],
      poolReserves[key][1],
      poolReserves[key][0].mul(99).div(100),
      poolReserves[key][1].mul(99).div(100),
      signer.address,
      timeUtils.now() + timeUtils.duration.hours(1)
    )
    .then((tx) => tx.wait());
  console.log(`${key}: Add liquidity success`);
};

const addLiquidityKUB = async (
  signer: SignerWithAddress,
  yesToken: YESToken,
  swapRouter: TestDiamonRouter
) => {
  const addressList = await addressUtils.getAddressList(hre.network.name);

  console.log("Provide: ", +formatEther(poolReserves.KUBYES[0]) + " " + "KUB");
  console.log("Provide: ", +formatEther(poolReserves.KUBYES[1]) + " " + "YES");

  console.log(
    "Balance: ",
    await signer.provider
      .getBalance(signer.address)
      .then((res) => formatEther(res))
  );
  console.log(
    "YES: ",
    await yesToken.balanceOf(signer.address).then((res) => formatEther(res))
  );

  const kkub = await TestKKUB__factory.connect(addressList["KKUB"], signer);

  await kkub
    .approve(swapRouter.address, constants.MaxUint256)
    .then((tx) => tx.wait());

  await swapRouter
    .connect(signer)
    .addLiquidityETH(
      yesToken.address,
      poolReserves.KUBYES[1],
      poolReserves.KUBYES[1].mul(99).div(100),
      poolReserves.KUBYES[0].mul(99).div(100),
      signer.address,
      timeUtils.now() + timeUtils.duration.hours(1),
      { value: poolReserves.KUBYES[0] }
    )
    .then((tx) => tx.wait());
  console.log("Add liquidity KUB-YES success");
};

export const addSwapLiquidity = async () => {
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const [owner] = await getSigners();

  const kusdt = await TestKUSDT__factory.connect(addressList["KUSDT"], owner);
  // const kusdc = await KAP20.attach(addressList["KUSDC"]);
  const yesToken = await YESToken__factory.connect(addressList["YES"], owner);

  const swapRouter = await TestDiamonRouter__factory.connect(
    addressList["SwapRouter"],
    owner
  );

  await yesToken
    .connect(owner)
    .approve(swapRouter.address, hre.ethers.constants.MaxUint256)
    .then((tx) => tx.wait());
  console.log("Approve YES to Swap router success");

  await addLiquidity(owner, kusdt, yesToken, swapRouter, "KUSDTYES");
  // await addLiquidity(owner, kusdc, yesToken, swapRouter, "KUSDCYES");

  await addLiquidityKUB(owner, yesToken, swapRouter);
};
