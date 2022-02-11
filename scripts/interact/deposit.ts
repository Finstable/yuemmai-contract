import { constants } from "ethers";
import { formatEther, formatUnits, parseEther } from "ethers/lib/utils";
import hre, { ethers } from "hardhat";
import {
  ERC20__factory,
  KAP20Lending__factory,
  KAP20__factory,
  LendingContract__factory,
  SlidingWindowOracle__factory,
  YESPriceOracle__factory,
  YESVault__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";

async function main() {
  const [, owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const token = KAP20__factory.connect(addressList["KUSDT"], owner);
  const lending = KAP20Lending__factory.connect(
    addressList["KUSDTLending"],
    owner
  );

  await token
    .approve(lending.address, constants.MaxUint256)
    .then((tx) => tx.wait());

  const amount = "1";

  await lending
    .deposit(parseEther(amount), owner.address)
    .then((tx) => tx.wait());

  console.log("Deposited success");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
