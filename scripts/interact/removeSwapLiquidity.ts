import { formatEther, formatUnits } from "@ethersproject/units";
import { constants } from "ethers";
import hre from "hardhat";
import {
  DiamonPair__factory,
  KAP20__factory,
  TestDiamonFactory,
  TestDiamonFactory__factory,
  TestDiamonRouter__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import time from "../../utils/timeUtils";

const getPair = async (
  factory: TestDiamonFactory,
  tokenA: string,
  tokenB: string
) => {
  const tokens =
    Number(tokenA) < Number(tokenB) ? [tokenA, tokenB] : [tokenB, tokenA];
  const pairAddr = await factory.getPair(tokens[0], tokens[1]);
  const SwapPair = (await hre.ethers.getContractFactory(
    "DiamonPair"
  )) as DiamonPair__factory;
  return SwapPair.attach(pairAddr);
};

const removeLiquidity = async (token0: string, token1: string) => {
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const [owner] = await hre.ethers.getSigners();

  const swapRouter = TestDiamonRouter__factory.connect(
    addressList["SwapRouter"],
    owner
  );
  const swapFactoryAddr = await swapRouter.factory();
  const swapFactory = await TestDiamonFactory__factory.connect(
    swapFactoryAddr,
    owner
  );

  const pair = await getPair(
    swapFactory,
    addressList[token0],
    addressList[token1]
  );

  let lpBalance = await pair.balanceOf(owner.address);
  console.log(`${token0}_${token1} LP: `, formatEther(lpBalance));

  const token0Contract = KAP20__factory.connect(addressList[token0], owner);
  const token1Contract = KAP20__factory.connect(addressList[token1], owner);

  const decimals0 = await token0Contract.decimals();
  const decimals1 = await token1Contract.decimals();

  console.log(
    `${token0} balance: `,
    await token0Contract
      .balanceOf(owner.address)
      .then((res) => formatUnits(res, decimals0))
  );
  console.log(
    `${token1} balance: `,
    await token1Contract
      .balanceOf(owner.address)
      .then((res) => formatUnits(res, decimals1))
  );

  await pair
    .approve(swapRouter.address, constants.MaxUint256)
    .then((tx) => tx.wait());

  const deadline = time.now() + time.duration.minutes(20);

  await swapRouter
    .removeLiquidity(
      addressList[token0],
      addressList[token1],
      lpBalance,
      0,
      0,
      owner.address,
      deadline
    )
    .then((tx) => tx.wait());
  console.log("Redeem success");

  lpBalance = await pair.balanceOf(owner.address);
  console.log(`${token0}_${token1} LP: `, formatEther(lpBalance));

  console.log(
    `${token0} balance: `,
    await token0Contract
      .balanceOf(owner.address)
      .then((res) => formatUnits(res, decimals0))
  );
  console.log(
    `${token1} balance: `,
    await token1Contract
      .balanceOf(owner.address)
      .then((res) => formatUnits(res, decimals1))
  );
};

const removeLiquidityETH = async (token: string) => {
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const [owner] = await hre.ethers.getSigners();

  const swapRouter = TestDiamonRouter__factory.connect(
    addressList["SwapRouter"],
    owner
  );
  const swapFactoryAddr = await swapRouter.factory();
  const swapFactory = await TestDiamonFactory__factory.connect(
    swapFactoryAddr,
    owner
  );

  const pair = await getPair(
    swapFactory,
    addressList[token],
    addressList["KKUB"]
  );

  let lpBalance = await pair.balanceOf(owner.address);
  console.log(`KKUB_${token} LP: `, formatEther(lpBalance));

  const tokenContract = KAP20__factory.connect(addressList[token], owner);

  const decimals = await tokenContract.decimals();

  console.log(
    `${token} balance: `,
    await tokenContract
      .balanceOf(owner.address)
      .then((res) => formatUnits(res, decimals))
  );
  console.log(
    `KUB balance: `,
    await owner.provider
      .getBalance(owner.address)
      .then((res) => formatEther(res))
  );

  await pair
    .approve(swapRouter.address, constants.MaxUint256)
    .then((tx) => tx.wait());

  const deadline = time.now() + time.duration.minutes(20);

  await swapRouter
    .removeLiquidityETH(
      addressList[token],
      lpBalance,
      0,
      0,
      owner.address,
      deadline
    )
    .then((tx) => tx.wait());
  console.log("Redeem success");

  lpBalance = await pair.balanceOf(owner.address);
  console.log(`KKUB_${token} LP: `, formatEther(lpBalance));

  console.log(
    `${token} balance: `,
    await tokenContract
      .balanceOf(owner.address)
      .then((res) => formatUnits(res, decimals))
  );
  console.log(
    `KUB balance: `,
    await owner.provider
      .getBalance(owner.address)
      .then((res) => formatEther(res))
  );
};

async function main() {
  // await removeLiquidity('KBTC', 'YES');
  // await removeLiquidity('KETH', 'YES');
  // await removeLiquidity('KDAI', 'YES');
  // await removeLiquidity('KUSDT', 'YES');
  // await removeLiquidity('KUSDC', 'YES');
  await removeLiquidityETH("YES");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
