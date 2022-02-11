import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { formatEther, parseEther } from "ethers/lib/utils";
import hre from "hardhat";
import {
  YESToken__factory,
  SwapRouter__factory,
  MintableToken,
  MintableToken__factory,
  SwapRouter,
  YESToken,
  SwapFactory__factory,
  SwapPair__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import timeUtils from "../../utils/timeUtils";

// Public sale YES = 1,200,000 YES. Split into 5 parts, 240,000 per part
// Alpha test: Public sale = 40,000,000. split  into 4 parts, 10,000,000 YES per part

const poolReserves = {
  // 'KUBYES': [
  //     hre.ethers.utils.parseEther('3000'),      // 1 KUB = 32.75 THB = 0.75 USD
  //     hre.ethers.utils.parseEther('3672')    // 1 YES = 26.74 THB = 0.8 USD
  // ],
  KUBYES: [
    hre.ethers.utils.parseEther("3000"), // 1 KUB = 32.75 THB = 0.75 USD
    hre.ethers.utils.parseEther("3672"), // 1 YES = 26.74 THB = 0.8 USD
  ],
  KBTCYES: [
    hre.ethers.utils.parseEther("127.77"), // 1 KBTC = 1,465,000 THB = 62,610 USD
    hre.ethers.utils.parseEther("10000000"), // 1 YES = 26.74 THB = 0.8 USD
  ],
  KETHYES: [
    hre.ethers.utils.parseEther("1904.76"), // 1 ETH = 139,020.00 THB = 4,200 USD
    hre.ethers.utils.parseEther("10000000"), // 1 YES = 26.74 THB = 0.8 USD
  ],
  KDAIYES: [
    hre.ethers.utils.parseEther("8000000"), // 1 KDAI = 33.43 THB = 1 USD
    hre.ethers.utils.parseEther("10000000"), // 1 YES = 26.74 THB = 0.8 USD
  ],
  KUSDCYES: [
    hre.ethers.utils.parseEther("8000000"), // 1 KUSDC = 33.43 THB = 1 USD
    hre.ethers.utils.parseEther("10000000"), // 1 YES = 26.74 THB = 0.8 USD
  ],
  KUSDTYES: [
    hre.ethers.utils.parseEther("8000000"), // 1 KUSDT = 33.43 THB = 1 USD
    hre.ethers.utils.parseEther("10000000"), // 1 YES = 26.74 THB = 0.8 USD
  ],
};

const getGasPrice = (signer: SignerWithAddress, addPercent = 120) =>
  signer.getGasPrice().then((price) => price.mul(addPercent).div(100));

const addLiquidity = async (
  signer: SignerWithAddress,
  token: MintableToken,
  yesToken: YESToken,
  swapRouter: SwapRouter,
  key: string
) => {
  // await token.mint(signer.address, poolReserves[key][0], { gasPrice: await getGasPrice(signer, 110) }).then(tx => tx.wait());
  // console.log(`${key}: Mint success`);
  await token
    .approve(swapRouter.address, hre.ethers.constants.MaxUint256)
    .then((tx) => tx.wait());
  // console.log(`${key}: Approve to Swap router success`);

  // console.log("Provide: ", + poolReserves[key][0] + " " + key);
  // console.log("Provide: ", + poolReserves[key][1] + " " + "YES");

  // console.log("Balance: " + await token.balanceOf(signer.address) + " " + key);
  // console.log("Balance: " + await yesToken.balanceOf(signer.address) + " " + "YES");
  // console.log("Allowance: " + await token.allowance(signer.address, swapRouter.address) + " " + key);
  // console.log("Allowance: " + await yesToken.allowance(signer.address, swapRouter.address) + " " + key);

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
      timeUtils.now() + timeUtils.duration.hours(1),
      { gasPrice: await getGasPrice(signer, 150) }
    )
    .then((tx) => tx.wait());
  console.log(`${key}: Add liquidity success`);
};

async function main() {
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const [owner] = await hre.ethers.getSigners();

  const txDeadline = timeUtils.now() + timeUtils.duration.years(20);

  // const KBTC = await hre.ethers.getContractFactory('KBTC') as MintableToken__factory;
  // const KETH = await hre.ethers.getContractFactory('KETH') as MintableToken__factory;
  // const KDAI = await hre.ethers.getContractFactory('KDAI') as MintableToken__factory;
  // const KUSDT = await hre.ethers.getContractFactory('KUSDT') as MintableToken__factory;
  // const KUSDC = await hre.ethers.getContractFactory('KUSDC') as MintableToken__factory;
  // const YESToken = (await hre.ethers.getContractFactory('YESToken')) as YESToken__factory;
  const SwapRouter = (await hre.ethers.getContractFactory(
    "SwapRouter"
  )) as SwapRouter__factory;

  // const kbtc = await KBTC.attach(addressList.kbtc);
  // const keth = await KETH.attach(addressList.keth);
  // const kdai = await KDAI.attach(addressList.kdai);
  // const kusdt = await KUSDT.attach(addressList.kusdt);
  // const kusdc = await KUSDC.attach(addressList.kusdc);
  // const yesToken = await YESToken.attach(addressList.yesToken);

  const swapRouter = await SwapRouter.attach(addressList["SwapRouter"]);
  const swapFactory = SwapFactory__factory.connect(addressList["SwapFactory"], owner);

  // await yesToken.connect(owner).approve(swapRouter.address, hre.ethers.constants.MaxUint256, { gasPrice: await getGasPrice(owner) }).then(tx => tx.wait());
  // console.log("Approve YES to Swap router success");

  // await addLiquidity(owner, kbtc, yesToken, swapRouter, 'KBTCYES');
  // await addLiquidity(owner, keth, yesToken, swapRouter, 'KETHYES');
  // await addLiquidity(owner, kdai, yesToken, swapRouter, 'KDAIYES');
  // await addLiquidity(owner, kusdt, yesToken, swapRouter, 'KUSDTYES');
  // await addLiquidity(owner, kusdc, yesToken, swapRouter, 'KUSDCYES');

  console.log("Owner: ", owner.address);

  const CDSAddr = "0xD3D631EE9E705254B5B935c2fF83AF8Ef7816065";
  const cds = MintableToken__factory.connect(CDSAddr, owner);

  console.log("Trade 100 KUB to CDS ", await swapRouter.getAmountsOut(parseEther('100'), [addressList["KKUB"], CDSAddr]).then(res => formatEther(res[res.length - 1])));

//   console.log(
//     "CDS balance",
//     await cds.balanceOf(owner.address).then((res) => formatEther(res))
//   );

//   console.log(
//     "KUB balance",
//     await owner.provider
//       .getBalance(owner.address)
//       .then((res) => formatEther(res))
//   );

//   const pairAddr = await swapFactory.getPair(CDSAddr,addressList["KKUB"]);
//   const pair = SwapPair__factory.connect(pairAddr, owner);

//   const reserves = await  pair.getReserves();

//   const amountA = poolReserves.KUBYES[0] 
//   const amountB = await swapRouter.quote(amountA, reserves[0], reserves[1]);

//   console.log({
//       amountA: formatEther(amountA),
//       amountB: formatEther(amountB)
//   })

//   await swapRouter
//     .connect(owner)
//     .addLiquidityETH(
//       CDSAddr,
//       amountB,
//       amountB.mul(50).div(100),
//       amountA.mul(50).div(100),
//       owner.address,
//       txDeadline,
//       { value: amountA }
//     )
//     .then((tx) => tx.wait());

//   console.log("Add liquidity KUB-YES success");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
