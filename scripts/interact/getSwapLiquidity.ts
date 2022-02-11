import { formatEther, formatUnits } from "@ethersproject/units";
import { constants } from "ethers";
import hre from "hardhat";
import { SwapRouter__factory, SwapFactory__factory, SwapFactory, SwapPair__factory, MintableToken__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import time from "../../utils/timeUtils";

const getPair = async (factory: SwapFactory, tokenA: string, tokenB: string) => {
    const tokens = Number(tokenA) < Number(tokenB) ? [tokenA, tokenB] : [tokenB, tokenA];
    const pairAddr = await factory.getPair(tokens[0], tokens[1]);
    const SwapPair = await hre.ethers.getContractFactory('SwapPair') as SwapPair__factory;
    return SwapPair.attach(pairAddr);
}

const getLiquidity = async (token0: string, token1: string) => {
    const addressList = await addressUtils.getAddressList(hre.network.name);
    const [owner] = await hre.ethers.getSigners();

    const swapRouter = SwapRouter__factory.connect(addressList['SwapRouter'], owner);
    const swapFactoryAddr = await swapRouter.factory();
    const swapFactory = await SwapFactory__factory.connect(swapFactoryAddr, owner);

    const pair = await getPair(swapFactory, addressList[token0], addressList[token1]);

    const [r0, r1] = await pair.getReserves();
    const t0 = await pair.token0();
    const t1 = await pair.token1();

    console.log('t0: ', t0);
    console.log('t1: ', t1);

    console.log("r0: ", formatEther(r0))
    console.log("r1: ", formatEther(r1))
}

async function main() {
    await getLiquidity('KKUB', 'YES');
    await getLiquidity('KBTC', 'YES');
    await getLiquidity('KETH', 'YES');
    await getLiquidity('KUSDT', 'YES');
    await getLiquidity('KUSDC', 'YES');
    await getLiquidity('KDAI', 'YES');
    // await getLiquidityETH('YES');
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
