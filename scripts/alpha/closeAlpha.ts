import { parseEther } from "ethers/lib/utils";
import hre from "hardhat";
import { YESController__factory, JumpRateModel__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";

async function main() {
    const addressList = await addressUtils.getAddressList(hre.network.name);

    const YESController = await hre.ethers.getContractFactory("YESController") as YESController__factory;
    const controller = await YESController.attach(addressList.yesController);
    // await interestRateModel.deployTransaction.wait();

    await controller._setMintPaused(addressList.lkub, false).then(tx => tx.wait());
    console.log("LKUB: ", await controller.mintGuardianPaused(addressList.lkub))

    await controller._setMintPaused(addressList.lkbtc, false).then(tx => tx.wait());
    console.log("LKBTC: ", await controller.mintGuardianPaused(addressList.lkbtc))

    await controller._setMintPaused(addressList.lketh, false).then(tx => tx.wait());
    console.log("LKETH: ", await controller.mintGuardianPaused(addressList.lketh))

    await controller._setMintPaused(addressList.lkusdt, false).then(tx => tx.wait());
    console.log("LKUSDT: ", await controller.mintGuardianPaused(addressList.lkusdt))

    await controller._setMintPaused(addressList.lkusdc, false).then(tx => tx.wait());
    console.log("LKUSDC: ", await controller.mintGuardianPaused(addressList.lkusdc))

    await controller._setMintPaused(addressList.lkdai, false).then(tx => tx.wait());
    console.log("LKDAI: ", await controller.mintGuardianPaused(addressList.lkdai))

    console.log("Set success");

    // console.log("Interest Rate Model: ", interestRateModel.address);
    // await addressUtils.saveAddresses(hre.network.name, { interestRateModel: interestRateModel.address });
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
