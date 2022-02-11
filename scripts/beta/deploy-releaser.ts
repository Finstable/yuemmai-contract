import { parseEther } from "ethers/lib/utils";
import hre, { ethers } from "hardhat";
import { Releaser__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import timeUtils from "../../utils/timeUtils";

async function main() {
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const Releaser = (await ethers.getContractFactory(
    "Releaser"
  )) as Releaser__factory;

  const releaseRate = parseEther("10");
  const maxElapse = timeUtils.duration.minutes(5);

  const releaser = await Releaser.deploy(
    releaseRate,
    maxElapse,
    addressList["YESVault"],
    addressList["YESController"],
    addressList["AdminProjectRouter"]
  );

  await releaser.deployTransaction.wait();

  console.log("Deployed Releaser to: ", releaser.address);

  await addressUtils.saveAddresses(hre.network.name, { Releaser: releaser.address });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
