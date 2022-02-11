import { formatEther, formatUnits, parseEther } from "ethers/lib/utils";
import hre, { ethers } from "hardhat";
import { ERC20__factory, LendingContract__factory, SlidingWindowOracle__factory, YESPriceOracle__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";

async function main() {
    const [owner] = await ethers.getSigners();
    const addressList = await addressUtils.getAddressList(hre.network.name);


    const yesPriceOracle = YESPriceOracle__factory.connect(addressList["YESPriceOracle"], owner);
    const slidingWindowOracle = SlidingWindowOracle__factory.connect(addressList["SlidingWindowOracle"], owner);

    console.log("Sliding window: ", await yesPriceOracle.swapOracle());
    console.log("Sliding window: ", addressList["SlidingWindowOracle"]);
    console.log("Window size: ", await slidingWindowOracle.windowSize());

    console.log("KUB: ", await yesPriceOracle.getLatestPrice(addressList["KKUB"]).then(res => formatEther(res)));
    // console.log("KBTC: ", await yesPriceOracle.getLatestPrice(addressList["KBTC"]).then(res => formatEther(res)));
    console.log("KUSDT: ", await yesPriceOracle.getLatestPrice(addressList["KUSDT"]).then(res => formatEther(res)));
    // console.log("KETH: ", await yesPriceOracle.getLatestPrice(addressList["KETH"]).then(res => formatEther(res)));
    // console.log("KDAI: ", await yesPriceOracle.getLatestPrice(addressList["KDAI"]).then(res => formatEther(res)));
    // console.log("KUSDC: ", await yesPriceOracle.getLatestPrice(addressList["KUSDC"]).then(res => formatEther(res)));

    console.log('YES: ', await yesPriceOracle.getYESPrice().then(res => formatEther(res)));

    console.log("Stable coins: ", await yesPriceOracle.stableCoins(0));
    console.log("Stable coins: ", await yesPriceOracle.stableCoins(1));
    console.log("Stable coins: ", await yesPriceOracle.stableCoins(2));
    console.log("Stable coins: ", await yesPriceOracle.stableCoins(3));
    console.log("Stable coins: ", await yesPriceOracle.stableCoins(4));

    // await yesPriceOracle._removeStableCoin(3).then(tx => tx.wait());
    // await yesPriceOracle._removeStableCoin(4).then(tx => tx.wait());
    // await yesPriceOracle._removeStableCoin(5).then(tx => tx.wait());


    // console.log("KUSDC: ", await yesPriceOracle.getLatestPrice(await yesPriceOracle.stableCoins(0)).then(res => formatEther(res)));
    // console.log("KUSDC: ", await yesPriceOracle.getLatestPrice(await yesPriceOracle.stableCoins(1)).then(res => formatEther(res)));
    // console.log("KUSDC: ", await yesPriceOracle.getLatestPrice(await yesPriceOracle.stableCoins(2)).then(res => formatEther(res)));
    // console.log("KUSDC: ", await yesPriceOracle.getLatestPrice(await yesPriceOracle.stableCoins(3)).then(res => formatEther(res)));
    // console.log("KUSDC: ", await yesPriceOracle.getLatestPrice(await yesPriceOracle.stableCoins(4)).then(res => formatEther(res)));
    // console.log("KUSDC: ", await yesPriceOracle.getLatestPrice(await yesPriceOracle.stableCoins(5)).then(res => formatEther(res)));

    
    // const slidingWindowOracle = SlidingWindowOracle__factory.connect(addressList.slidingWindowOracle, owner);
    // console.log("Factory: " + await slidingWindowOracle.factory())

    // console.log("KKUB-YES price: ", await getTokenPrice(addressList["KUBLending"]));
    // console.log("KBTC-YES price: ", await getTokenPrice(addressList["KBTCLending"]));
    // console.log("KETH-YES price: ", await getTokenPrice(addressList["KETHLending"]));
    // console.log("KDAI-YES price: ", await getTokenPrice(addressList["KDAILending"]));
    // console.log("KUSDC-YES price: ", await getTokenPrice(addressList["KUSDCLending"]));
    // console.log("KUSDT-YES price: ", await getTokenPrice(addressList["KUSDTLending"]));

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
