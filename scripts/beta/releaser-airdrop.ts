import { formatEther, parseEther } from "ethers/lib/utils";
import hre, { ethers } from "hardhat";
import { Releaser__factory, YESVault__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import timeUtils from "../../utils/timeUtils";

async function main() {
  const [,owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const releaser = Releaser__factory.connect(addressList["Releaser"], owner);
  const vault = YESVault__factory.connect(addressList["YESVault"], owner);

  console.log(
    "Vault tokens: ",
    await vault.tokensOf(owner.address).then((res) => formatEther(res))
  );
  console.log(
    "Release amount: ",
    await releaser
      .getCurrentRelease(owner.address)
      .then((res) => formatEther(res))
  );

  await releaser.release(owner.address).then(tx => tx.wait());

  console.log(
    "Vault tokens: ",
    await vault.tokensOf(owner.address).then((res) => formatEther(res))
  );
  console.log(
    "Release amount: ",
    await releaser
      .getCurrentRelease(owner.address)
      .then((res) => formatEther(res))
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
