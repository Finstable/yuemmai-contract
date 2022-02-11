import { formatEther, parseEther } from "@ethersproject/units";
import { ethers, network } from "hardhat";
import {
  KUBLending__factory,
  YESController__factory,
  YESToken__factory,
  YESVault,
  YESVault__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";

async function main() {
  const [owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(network.name);

  const kubLending = KUBLending__factory.connect(addressList['KUBLending'], owner);
  const kbtcLending = KUBLending__factory.connect(addressList['KBTCLending'], owner);
  const kethLending = KUBLending__factory.connect(addressList['KETHLending'], owner);
  const kusdtLending = KUBLending__factory.connect(addressList['KUSDTLending'], owner);
  const kusdcLending = KUBLending__factory.connect(addressList['KUSDCLending'], owner);
  const kdaiLending = KUBLending__factory.connect(addressList['KDAILending'], owner);
  const vault = YESVault__factory.connect(addressList['YESVault'], owner);

  // console.log("Oracle: ", await controller.oracle());
  // console.log("Markets: ", await controller.allMarkets());

  await kubLending._setController(addressList['YESController']).then(tx => tx.wait());
  await kbtcLending._setController(addressList['YESController']).then(tx => tx.wait());
  await kethLending._setController(addressList['YESController']).then(tx => tx.wait());
  await kusdtLending._setController(addressList['YESController']).then(tx => tx.wait());
  await kusdcLending._setController(addressList['YESController']).then(tx => tx.wait());
  await kdaiLending._setController(addressList['YESController']).then(tx => tx.wait());

  console.log("KUB controller: ", await kubLending.controller());
  console.log("KBTC controller: ", await kbtcLending.controller());
  console.log("KETH controller: ", await kethLending.controller());
  console.log("KUSDT controller: ", await kusdtLending.controller());
  console.log("KUSDC controller: ", await kusdcLending.controller());
  console.log("KDAI controller: ", await kdaiLending.controller());
  console.log("KDAI controller: ", await kdaiLending.controller());
  console.log("Vault controller: ", await vault.controller());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
