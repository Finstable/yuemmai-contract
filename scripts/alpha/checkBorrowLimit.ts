import { formatEther } from "@ethersproject/units";
import { ethers, network } from "hardhat";
import { YESController__factory, YESToken__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";

async function main() {
    const [owner] = await ethers.getSigners();
    const addressList = await addressUtils.getAddressList(network.name);

    const address = '0xa90AbFCfB3DF831Ef02b0A3d23A8752f97F16477';

    const controller = YESController__factory.connect(addressList['YesController'], owner);

    console.log("Borrow limit: ", await controller.borrowLimitOf(address).then(res => formatEther(res)));

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
