import { formatEther, parseEther } from "ethers/lib/utils";
import hre, { ethers } from "hardhat";
import {
  KKUB__factory,
  KUBLending__factory,
  Releaser__factory,
  YESToken__factory,
  YESVault__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import timeUtils from "../../utils/timeUtils";

async function main() {
  const [owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const yes = YESToken__factory.connect(addressList["YES"], owner);
  const vault = YESVault__factory.connect(addressList["YESVault"], owner);

  const amount = parseEther("500000");

  console.log(
    "YES balance: ",
    await yes.balanceOf(owner.address).then((res) => formatEther(res))
  );

  await yes.transfer(vault.address, amount).then((tx) => tx.wait());

  console.log(
    "Vault balance: ",
    await yes.balanceOf(vault.address).then((res) => formatEther(res))
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
