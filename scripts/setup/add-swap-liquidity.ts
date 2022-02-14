import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { constants } from "ethers";
import { formatEther, parseEther } from "ethers/lib/utils";
import hre from "hardhat";
import {
  YESToken__factory,
  YESToken,
  KAP20,
  TestDiamonRouter,
  TestDiamonRouter__factory,
  TestKKUB__factory,
  TestKUSDT,
  TestKUSDT__factory,
  KAP20__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import timeUtils from "../../utils/timeUtils";
import { getSigners } from "../utils/getSigners";

const poolReserves = {
  KUBYES: [
    hre.ethers.utils.parseEther("204454"), // 1 KUB = 12.93 USD
    hre.ethers.utils.parseEther("2500000"), // 1 YES = 26.74 THB = 0.8 USD
  ],
  KUSDTYES: [
    hre.ethers.utils.parseEther("1000000"), // 1 KUSDT = 33.43 THB = 1 USD
    hre.ethers.utils.parseEther("1250000"), // 1 YES = 26.74 THB = 0.8 USD
  ],
  KUSDCYES: [
    hre.ethers.utils.parseEther("1000000"), // 1 KUSDT = 33.43 THB = 1 USD
    hre.ethers.utils.parseEther("1250000"), // 1 YES = 26.74 THB = 0.8 USD
  ],
};

const inputs = {
  KUB: parseEther("53000"),
  KUSDT: parseEther("250000"),
  KUSDC: parseEther("250000"),
};

const outputs = {
  KUB: parseEther("503300"),
  KUSDT: parseEther("240000"),
  KUSDC: parseEther("240000"),
};

const addLiquidity = async (
  signer: SignerWithAddress,
  token: KAP20 | TestKUSDT,
  yesToken: YESToken,
  swapRouter: TestDiamonRouter,
  key: string
) => {
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

const buyToken = async (
  signer: SignerWithAddress,
  yesToken: YESToken,
  tokenName: string
) => {
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const deadline = timeUtils.now() + timeUtils.duration.minutes(10);

  const swapRouter = TestDiamonRouter__factory.connect(
    addressList["SwapRouter"],
    signer
  );
  const tokenAddr = addressList[tokenName];

  console.log(
    inputs[tokenName],
    outputs[tokenName],
    [tokenAddr, yesToken.address],
    signer.address,
    deadline,
    {
      gasPrice: 50000000000, // 50 GWEI
    }
  );

  await swapRouter
    .swapExactTokensForTokens(
      inputs[tokenName],
      outputs[tokenName],
      [tokenAddr, yesToken.address],
      signer.address,
      deadline,
      {
        gasPrice: 50000000000, // 50 GWEI
      }
    )
    .then((tx) => tx.wait());

  console.log(
    "YES balance: ",
    await yesToken.balanceOf(signer.address).then((res) => formatEther(res))
  );
};

const buyTokenWithKUB = async (
  signer: SignerWithAddress,
  yesToken: YESToken
) => {
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const deadline = timeUtils.now() + timeUtils.duration.minutes(10);

  const swapRouter = TestDiamonRouter__factory.connect(
    addressList["SwapRouter"],
    signer
  );
  const tokenAddr = addressList["KKUB"];
  await swapRouter
    .swapExactETHForTokens(
      outputs["KUB"],
      [tokenAddr, yesToken.address],
      signer.address,
      deadline,
      {
        value: inputs["KUB"],
        gasPrice: 50000000000, // 50 GWEI
      }
    )
    .then((tx) => tx.wait());

  console.log(
    "Trade success! YES balance: ",
    await yesToken.balanceOf(signer.address).then((res) => formatEther(res))
  );
};

export const addSwapLiquidity = async () => {
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const [owner, signer] = await getSigners();

  const kusdt = await TestKUSDT__factory.connect(addressList["KUSDT"], owner);
  const kusdc = await TestKUSDT__factory.connect(addressList["KUSDC"], owner);
  const yesToken = await YESToken__factory.connect(addressList["YES"], owner);

  const swapRouter = await TestDiamonRouter__factory.connect(
    addressList["SwapRouter"],
    owner
  );

  // KUSDC
  // await Promise.all([
  await addLiquidity(owner, kusdc, yesToken, swapRouter, "KUSDCYES");
  await buyToken(signer, yesToken, "KUSDC");
  // ]);

  // KUSDT
  // await Promise.all([
  await addLiquidity(owner, kusdt, yesToken, swapRouter, "KUSDTYES");
  await buyToken(signer, yesToken, "KUSDT");
  // ]);

  // KUB
  // await Promise.all([
  // await addLiquidityKUB(owner, yesToken, swapRouter);
  // await buyTokenWithKUB(signer, yesToken);
  // ])
};
