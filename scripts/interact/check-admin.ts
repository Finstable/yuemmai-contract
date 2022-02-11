import { parseEther } from "@ethersproject/units";
import hre, { ethers } from "hardhat";
import { AdminProject__factory, YESToken__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";

async function main() {
    const [owner] = await ethers.getSigners();
    const addressList = await addressUtils.getAddressList(hre.network.name);
    const adminProject = AdminProject__factory.connect(addressList['AdminProject'], owner);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
