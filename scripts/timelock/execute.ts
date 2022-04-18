import {
  KAP20Lending,
  KAP20Lending__factory,
  KUBLending__factory,
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

  const kubLending = KUBLending__factory.connect(
    addressList["KUBLending"],
    signer
  );

  const kusdcLending = KAP20Lending__factory.connect(
    addressList["KUSDTLending"],
    signer
  );

  // const eta = 1649738526;
  const eta = 1650336151;
  const now = timeUtils.now();

  console.log({ eta, now, waitFor: eta - now });

  await timelock
    .executeTransaction(
      kubLending.address,
      0,
      "",
      kubLending.interface.encodeFunctionData("acceptSuperAdmin"),
      eta
    )
    .then((tx) => tx.wait());

  console.log("Execute KUB Lending success");

  await timelock
    .executeTransaction(
      kusdcLending.address,
      0,
      "",
      kusdcLending.interface.encodeFunctionData("acceptSuperAdmin"),
      eta
    )
    .then((tx) => tx.wait());

  console.log("Execute KUSDC Lending success");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
