import hre from "hardhat";
import { SwapFactory__factory } from "../../typechain";
import addressUtils from '../../utils/addressUtils';

async function main() {
    const addressList = await addressUtils.getAddressList(hre.network.name);
    const [owner] = await hre.ethers.getSigners();

    const uniswapFactory = SwapFactory__factory.connect(addressList.swapFactory, owner);

    console.log("Code Hash: " + await uniswapFactory.INIT_CODE_PAIR_HASH());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
