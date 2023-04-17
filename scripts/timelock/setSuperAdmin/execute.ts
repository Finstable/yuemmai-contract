import { Timelock__factory, YESController__factory } from "../../../typechain";
import addressUtils from "../../../utils/addressUtils";
import { getSigners } from "../../utils/getSigners";
import hre from "hardhat";
import timeUtils from "../../../utils/timeUtils";

// npx hardhat run scripts/timelock/setSuperAdmin/execute.ts --network kubchain

async function main() {
  const [signer] = await getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const timelock = Timelock__factory.connect(addressList["Timelock"], signer);

  const yesController = YESController__factory.connect(
    addressList["YESController"],
    signer
  );

  const eta = 1681785887;
  const now = timeUtils.now();

  console.log({ eta, now, waitFor: eta - now });

  await timelock
    .executeTransaction(
      yesController.address,
      0,
      "",
      yesController.interface.encodeFunctionData("setPendingSuperAdmin", [
        signer.address,
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
