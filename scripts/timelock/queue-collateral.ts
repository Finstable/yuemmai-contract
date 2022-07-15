import {
  KAP20Lending,
  KAP20Lending__factory,
  KUBLending__factory,
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

  const yesController = YESController__factory.connect(
    addressList["YESController"],
    signer
  );

  const eta =
    timeUtils.now() +
    timeUtils.duration.days(1) +
    timeUtils.duration.minutes(5);
  // const eta = Math.floor(new Date("2022-04-14").valueOf() / 1000);
  console.log({ eta });

  await timelock
    .queueTransaction(
      yesController.address,
      0,
      "",
      yesController.interface.encodeFunctionData("setCollateralFactor", [
        parseEther("0.75"),
      ]),
      eta
    )
    .then((tx) => tx.wait());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
