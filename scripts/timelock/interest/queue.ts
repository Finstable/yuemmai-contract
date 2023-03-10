import {
  KAP20Lending,
  KAP20Lending__factory,
  KUBLending__factory,
  Timelock__factory,
  YESController,
  YESController__factory,
  YESVault__factory,
} from "../../../typechain";
import addressUtils from "../../../utils/addressUtils";
import { getSigners } from "../../utils/getSigners";
import hre from "hardhat";
import timeUtils from "../../../utils/timeUtils";
import { parseEther } from "ethers/lib/utils";

async function main() {
  const [signer] = await getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const timelock = Timelock__factory.connect(addressList["Timelock"], signer);

  const lending = KAP20Lending__factory.connect(
    addressList["KUSDTLending"],
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
      lending.address,
      0,
      "",
      lending.interface.encodeFunctionData("_setInterestRateModel", [
        addressList["InterestRateModel"],
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
