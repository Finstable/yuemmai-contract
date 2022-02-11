import { formatEther, formatUnits, parseEther } from "ethers/lib/utils";
import hre, { ethers } from "hardhat";
import {
  ERC20__factory,
  LendingContract__factory,
  SlidingWindowOracle__factory,
  YESPriceOracle__factory,
  YESVault__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";

async function main() {
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const [owner, user] = await ethers.getSigners();

  const vault = YESVault__factory.connect(addressList["YESVault"], owner);

  await vault.airdrop(owner.address, parseEther("1")).then((tx) => tx.wait());

  console.log(
    "Airdrop amount: ",
    await vault.releasedTo(owner.address).then((res) => formatEther(res))
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
