import {
  KAP20Lending__factory,
  Timelock__factory,
  YESController,
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

  const yesVault = YESVault__factory.connect(addressList["YESVault"], signer);
  const controller = YESController__factory.connect(
    addressList["YESController"],
    signer
  );
  const kusdtLending = KAP20Lending__factory.connect(
    addressList["KUSDTLending"],
    signer
  );

  const eta = timeUtils.now() + timeUtils.duration.days(1) + timeUtils.duration.minutes(5);
  console.log({ eta });

  await timelock
    .queueTransaction(
      yesVault.address,
      0,
      "",
      yesVault.interface.encodeFunctionData("acceptSuperAdmin"),
      eta
    )
    .then((tx) => tx.wait());

  console.log("Queue yes vault success");

  await timelock
    .queueTransaction(
      controller.address,
      0,
      "",
      controller.interface.encodeFunctionData("acceptSuperAdmin"),
      eta
    )
    .then((tx) => tx.wait());

  console.log("Queue controller success");

  await timelock
    .queueTransaction(
      kusdtLending.address,
      0,
      "",
      kusdtLending.interface.encodeFunctionData("acceptSuperAdmin"),
      eta
    )
    .then((tx) => tx.wait());

  console.log("Queue kusdtLending success");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
