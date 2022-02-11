import { formatEther, parseEther } from "@ethersproject/units";
import { ethers, network } from "hardhat";
import { KAP20Lending__factory, KAP20__factory, YESController__factory, YESToken__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";


async function main() {
    const [owner] = await ethers.getSigners();
    const addressList = await addressUtils.getAddressList(network.name);

    const lending = KAP20Lending__factory.connect(addressList['KUSDCLending'], owner);
    const lTokenAddr = await lending.lToken();

    const lToken = KAP20__factory.connect(lTokenAddr, owner);

    console.log("Balance: ", await lToken.balanceOf('0xcdCc562088F99f221B0C3BB1EDcFD5A9646D0B25').then(res => formatEther(res)));
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
