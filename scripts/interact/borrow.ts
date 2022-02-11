import { parseEther } from "@ethersproject/units";
import hre, { ethers } from "hardhat";
import { AdminProject__factory, KUBLending__factory, YESController, YESController__factory, YESToken__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";

const projectName = "yuemmai";

async function main() {
  const [owner, helper, test, user] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const adminProject = AdminProject__factory.connect(
    addressList["AdminProject"],
    owner
  );

  const controller = await YESController__factory.connect(addressList['YESController'], user);
  const kubLending = await KUBLending__factory.connect(addressList['KUBLending'], user);

//   await kubLending.borrow('1', kubLending.address).then(tx => tx.wait());

  console.log("Alloed: ", await controller.borrowAllowed(kubLending.address, user.address, '1'))

  console.log("borrow success");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
