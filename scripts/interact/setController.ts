import hre from "hardhat";
import { KUBLending__factory } from "../../typechain";
import addressUtils from '../../utils/addressUtils';

const main = async () => {
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const LKUB = await hre.ethers.getContractFactory("KUBLending") as KUBLending__factory;

  const lkub = await LKUB.attach(addressList.lkub);

//   await lkub._setController(addressList.yesController).then(tx => tx.wait());

  console.log("Setup controller to: ", await lkub.controller());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
