import { formatEther, parseEther } from "ethers/lib/utils";
import hre, { ethers } from "hardhat";
import { Releaser__factory, YESVault__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import timeUtils from "../../utils/timeUtils";

async function main() {
  const [owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const releaser = Releaser__factory.connect(addressList["Releaser"], owner);

  const releaseRate = parseEther("30");
  const maxElapse = timeUtils.duration.hours(1);

  await releaser.setMaxElapse(maxElapse).then(tx => tx.wait());
  console.log("Max elapse", await releaser.maxElapse());
  await releaser.setReleaseRate(releaseRate).then(tx => tx.wait());
  console.log("Release rate", await releaser.releaseRate().then(res => formatEther(res)));

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
