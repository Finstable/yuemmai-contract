import { formatEther, parseEther } from "ethers/lib/utils";
import hre, { ethers } from "hardhat";
import { Releaser__factory, YESVault__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import timeUtils from "../../utils/timeUtils";

async function main() {
  const [owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const releaser = Releaser__factory.connect(addressList["Releaser"], owner);

  console.log("Admin: ", await releaser.adminRouter());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
