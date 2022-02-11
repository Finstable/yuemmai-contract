import addressUtils from "../../utils/addressUtils";
import { deployController } from "../deploy/deploy-controller";
import hre, { ethers } from 'hardhat';
import { YESVault__factory, KAP20Lending__factory, KUBLending__factory } from "../../typechain";
import { setupController } from "../deploy/setup-controller";

async function main() {
    const [owner] = await ethers.getSigners();
    // await deployController();

    const addressList = await addressUtils.getAddressList(hre.network.name);

    const yesVault = YESVault__factory.connect(addressList['YESVault'], owner);
    const lkub = KUBLending__factory.connect(addressList['KUBLending'], owner);
    const lkbtc = KAP20Lending__factory.connect(addressList['KBTCLending'], owner);
    const lketh = KAP20Lending__factory.connect(addressList['KETHLending'], owner);
    const lkusdt = KAP20Lending__factory.connect(addressList['KUSDTLending'], owner);
    const lkusdc = KAP20Lending__factory.connect(addressList['KUSDCLending'], owner);
    const lkdai = KAP20Lending__factory.connect(addressList['KDAILending'], owner);

    await yesVault.setController(addressList['YESController']).then(tx => tx.wait());
    console.log("YES Vault changed controller to: ", await yesVault.controller());

    await lkub._setController(addressList['YESController']).then(tx => tx.wait());
    console.log("LKUB changed controller to: ", await lkub.controller());

    await lkbtc._setController(addressList['YESController']).then(tx => tx.wait());
    console.log("LKBTC changed controller to: ", await lkbtc.controller());

    await lketh._setController(addressList['YESController']).then(tx => tx.wait());
    console.log("LKETH changed controller to: ", await lketh.controller());

    await lkusdt._setController(addressList['YESController']).then(tx => tx.wait());
    console.log("LKUSDT changed controller to: ", await lkusdt.controller());

    await lkusdc._setController(addressList['YESController']).then(tx => tx.wait());
    console.log("LKUSDC changed controller to: ", await lkusdc.controller());

    await lkdai._setController(addressList['YESController']).then(tx => tx.wait());
    console.log("LKDAI changed controller to: ", await lkdai.controller());

    // await setupController();
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
