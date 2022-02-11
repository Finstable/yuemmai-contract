import hre, { ethers } from "hardhat";
import { SlidingWindowOracle__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";

async function main() {
    const [, owner] = await ethers.getSigners();
    const addressList = await addressUtils.getAddressList(hre.network.name);
    const slidingWindowOracle = SlidingWindowOracle__factory.connect(addressList['SlidingWindowOracle'], owner);

    await slidingWindowOracle.update(addressList['KKUB'], addressList['YES']).then(tx => tx.wait());
    console.log("Updated KKUB-YES price");

    await slidingWindowOracle.update(addressList['KBTC'], addressList['YES']).then(tx => tx.wait());
    console.log("Updated KBTC-YES price");

    await slidingWindowOracle.update(addressList['KETH'], addressList['YES']).then(tx => tx.wait());
    console.log("Updated KETH-YES price");

    await slidingWindowOracle.update(addressList['KDAI'], addressList['YES']).then(tx => tx.wait());
    console.log("Updated KDAI-YES price");

    await slidingWindowOracle.update(addressList['KUSDT'], addressList['YES']).then(tx => tx.wait());
    console.log("Updated KUSDT-YES price");

    await slidingWindowOracle.update(addressList['KUSDC'], addressList['YES']).then(tx => tx.wait());
    console.log("Updated KUSDC-YES price");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
