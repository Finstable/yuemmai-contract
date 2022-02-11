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

  const oracle = YESPriceOracle__factory.connect(
    addressList["YESPriceOracle"],
    owner
  );

  await oracle.addStableCoin(addressList['KDAI']).then(tx => tx.wait());
  await oracle.addStableCoin(addressList['KUSDT']).then(tx => tx.wait());
  await oracle.addStableCoin(addressList['KUSDC']).then(tx => tx.wait());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
