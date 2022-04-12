import {
  KAP20Lending,
  KAP20Lending__factory,
  Timelock__factory,
  YESController__factory,
  YESVault__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import { getSigners } from "../utils/getSigners";
import hre from "hardhat";
import timeUtils from "../../utils/timeUtils";
import { parseEther } from "ethers/lib/utils";

async function main() {
  const [signer] = await getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const timelock = Timelock__factory.connect(addressList["Timelock"], signer);

  const controller = YESController__factory.connect(
    addressList["YESController"],
    signer
  );

  // const eta = 1649738526;
  const eta = 1649894400;
  const now = timeUtils.now();

  console.log({ eta, now, waitFor: eta - now });

  // await timelock
  //   .executeTransaction(
  //     controller.address,
  //     0,
  //     "",
  //     controller.interface.encodeFunctionData("supportMarket", [addressList["KUBLending"]]),
  //     eta
  //   )
  //   .then((tx) => tx.wait());

  // console.log("Execute KUB Lending success");

  // await timelock
  //   .executeTransaction(
  //     controller.address,
  //     0,
  //     "",
  //     controller.interface.encodeFunctionData("supportMarket", [addressList["KUSDCLending"]]),
  //     eta
  //   )
  //   .then((tx) => tx.wait());

  // console.log("Execute KUSDC Lending success");

  await timelock
    .executeTransaction(
      controller.address,
      0,
      "",
      controller.interface.encodeFunctionData("setCollateralFactor", [parseEther("0.5")]),
      eta
    )
    .then((tx) => tx.wait());

  console.log("Execute set collateral factor success");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
