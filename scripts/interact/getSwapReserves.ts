import { formatUnits } from "@ethersproject/units";
import hre, { ethers } from "hardhat";
import { SwapFactory__factory, SwapPair__factory, ERC20__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";

// Public sale YES = 1,200,000 YES. Split into 5 parts, 240,000 per part
// Alpha test: Public sale = 40,000,000. split  into 4 parts, 10,000,000 YES per part

const poolReserves = {
    'KUBYES': [
        hre.ethers.utils.parseEther('5'),      // 1 KUB = 32.75 THB = 0.75 USD
        hre.ethers.utils.parseEther('6.12')    // 1 YES = 26.74 THB = 0.8 USD
    ],
    'KBTCYES': [
        hre.ethers.utils.parseEther('127.77'),  // 1 KBTC = 1,465,000 THB = 62,610 USD
        hre.ethers.utils.parseEther('10000000')   // 1 YES = 26.74 THB = 0.8 USD
    ],
    'KETHYES': [
        hre.ethers.utils.parseEther('1904.76'),    // 1 ETH = 139,020.00 THB = 4,200 USD
        hre.ethers.utils.parseEther('10000000')        // 1 YES = 26.74 THB = 0.8 USD
    ],
    'KDAIYES': [
        hre.ethers.utils.parseEther('8000000'),      // 1 KDAI = 33.43 THB = 1 USD
        hre.ethers.utils.parseEther('10000000')       // 1 YES = 26.74 THB = 0.8 USD
    ],
    'KUSDCYES': [
        hre.ethers.utils.parseEther('8000000'),      // 1 KUSDC = 33.43 THB = 1 USD
        hre.ethers.utils.parseEther('10000000')       // 1 YES = 26.74 THB = 0.8 USD
    ],
    'KUSDTYES': [
        hre.ethers.utils.parseEther('8000000'),      // 1 KUSDT = 33.43 THB = 1 USD
        hre.ethers.utils.parseEther('10000000')       // 1 YES = 26.74 THB = 0.8 USD
    ],
}

export const getPair = async (factoryAddr: string, token0Addr: string, token1Addr: string) => {
    const [owner] = await ethers.getSigners();
    const factory = SwapFactory__factory.connect(factoryAddr, owner);
    const pairAddr = await factory.getPair(token0Addr, token1Addr);
    return SwapPair__factory.connect(pairAddr, owner);
}

export const getReserves = async (factoryAddr: string, token0Addr: string, token1Addr: string) => {
    const [signer] = await ethers.getSigners();
    const pair = await getPair(factoryAddr, token0Addr, token1Addr);
    const token0 = await ERC20__factory.connect(token0Addr, signer)
    const token1 = await ERC20__factory.connect(token1Addr, signer)
    const reserves = await pair.getReserves();
    const [dec0, dec1] = await Promise.all([token0.decimals(), token1.decimals()]);
    return {
        reserve0: formatUnits(reserves._reserve0, dec0),
        reserve1: formatUnits(reserves._reserve1, dec1),
    }
}


async function main() {
    const addressList = await addressUtils.getAddressList(hre.network.name);

    console.log("KBTC-YES: ", await getReserves(addressList.swapFactory, addressList.kbtc, addressList.yesToken));
    console.log("KETH-YES: ", await getReserves(addressList.swapFactory, addressList.keth, addressList.yesToken));
    console.log("KDAI-YES: ", await getReserves(addressList.swapFactory, addressList.kdai, addressList.yesToken));
    console.log("KUSDT-YES: ", await getReserves(addressList.swapFactory, addressList.kusdt, addressList.yesToken));
    console.log("KUSDC-YES: ", await getReserves(addressList.swapFactory, addressList.kusdc, addressList.yesToken));
    console.log("KUB-YES: ", await getReserves(addressList.swapFactory, addressList.kkub, addressList.yesToken));
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
