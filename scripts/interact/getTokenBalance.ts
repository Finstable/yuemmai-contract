import { formatUnits } from "@ethersproject/units";
import hre, { ethers } from "hardhat";
import { ERC20__factory } from "../../typechain";
import addressUtils from '../../utils/addressUtils';

async function main() {
    const [owner] = await ethers.getSigners();
    const { YES } = await addressUtils.getAddressList(hre.network.name)

    const ERC20 = await hre.ethers.getContractFactory('ERC20') as ERC20__factory;

    const erc20 = ERC20.attach(YES);

    const decimals = await erc20.decimals()

    console.log("Token balance: ", await erc20.balanceOf(YES).then(res => formatUnits(res.toString(), decimals)));
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
