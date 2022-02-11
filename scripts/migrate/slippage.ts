import addressUtils from "../../utils/addressUtils";
import { deployController } from "../deploy/deploy-controller";
import hre, { ethers } from "hardhat";
import {
  YESVault__factory,
  KAP20Lending__factory,
  KUBLending__factory,
  YESController__factory,
} from "../../typechain";
import { setupController } from "../deploy/setup-controller";
import { formatEther, parseEther } from "ethers/lib/utils";

async function main() {
  const [owner] = await ethers.getSigners();

  const addressList = await addressUtils.getAddressList("kubchain_test");

  const vault = YESVault__factory.connect(addressList["YESVault"], owner);

  // const slippage = parseEther("1");

  // await vault._setSlippageTolerrance(slippage).then((tx) => tx.wait());

  console.log(
    "Set slippage to: ",
    await vault.slippageTolerrance().then((res) => formatEther(res))
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
