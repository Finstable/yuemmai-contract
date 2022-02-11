import { formatEther } from "@ethersproject/units";
import { constants } from "ethers";
import hre from "hardhat";
import { KKUB__factory, YESToken__factory, SwapRouter__factory, SwapFactory__factory, SwapFactory, SwapPair__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import time from "../../utils/timeUtils";

const getPair = async (factory: SwapFactory, tokenA: string, tokenB: string) => {
    const tokens = Number(tokenA) < Number(tokenB) ? [tokenA, tokenB] : [tokenB, tokenA];
    const pairAddr = await factory.getPair(tokens[0], tokens[1]);
    const SwapPair = await hre.ethers.getContractFactory('SwapPair') as SwapPair__factory;
    return SwapPair.attach(pairAddr);
}

async function main() {
    const addressList = await addressUtils.getAddressList(hre.network.name);
    const [owner] = await hre.ethers.getSigners();

    const KKUB = await hre.ethers.getContractFactory('KKUB') as KKUB__factory;
    const YESToken = (await hre.ethers.getContractFactory('YESToken')) as YESToken__factory;

    const SwapRouter = await hre.ethers.getContractFactory('SwapRouter') as SwapRouter__factory;
    const SwapFactory = await hre.ethers.getContractFactory('SwapFactory') as SwapFactory__factory;

    const kkub = await KKUB.attach(addressList.kkub);
    const yesToken = await YESToken.attach(addressList.yesToken);

    const swapRouter = await SwapRouter.attach(addressList.swapRouter);
    const swapFactoryAddr = await swapRouter.factory();
    const swapFactory = await SwapFactory.attach(swapFactoryAddr);

    const kubYES = await getPair(swapFactory, kkub.address, yesToken.address);
    const kbtcYES = await getPair(swapFactory, addressList.kbtc, yesToken.address);
    const kethYES = await getPair(swapFactory, addressList.keth, yesToken.address);
    const kusdtYES = await getPair(swapFactory, addressList.kusdt, yesToken.address);
    const kusdcYES = await getPair(swapFactory, addressList.kusdc, yesToken.address);
    const kdaiYES = await getPair(swapFactory, addressList.kdai, yesToken.address);

    const reserveKUBYES = await kubYES.getReserves().then(res => ({ r0: formatEther(res[0]), r1: formatEther(res[1]), ts: res[2] }));
    const reserveKBTCYES = await kbtcYES.getReserves().then(res => ({ r0: formatEther(res[0]), r1: formatEther(res[1]), ts: res[2] }));
    const reserveKETHYES = await kethYES.getReserves().then(res => ({ r0: formatEther(res[0]), r1: formatEther(res[1]), ts: res[2] }));
    const reserveKUSDTYES = await kusdtYES.getReserves().then(res => ({ r0: formatEther(res[0]), r1: formatEther(res[1]), ts: res[2] }));
    const reserveKUSDCYES = await kusdcYES.getReserves().then(res => ({ r0: formatEther(res[0]), r1: formatEther(res[1]), ts: res[2] }));
    const reserveKDAIYES = await kdaiYES.getReserves().then(res => ({ r0: formatEther(res[0]), r1: formatEther(res[1]), ts: res[2] }));

    console.log("Reserve KUBYES: ", reserveKUBYES)
    console.log("Reserve KBTCYES: ", reserveKBTCYES)
    console.log("Reserve KETHYES: ", reserveKETHYES)
    console.log("Reserve KUSDTYES: ", reserveKUSDTYES)
    console.log("Reserve KUSDCYES: ", reserveKUSDCYES)
    console.log("Reserve KDAIYES: ", reserveKDAIYES)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
