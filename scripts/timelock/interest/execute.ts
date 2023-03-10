import { KAP20Lending__factory, Timelock__factory } from "../../../typechain";
import addressUtils from "../../../utils/addressUtils";
import { getSigners } from "../../utils/getSigners";
import hre from "hardhat";

async function main() {
  const [signer] = await getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const timelock = Timelock__factory.connect(addressList["Timelock"], signer);

  const lending = KAP20Lending__factory.connect(
    addressList["KUSDTLending"],
    signer
  );

  const eta = 1678439625;
  // const eta = Math.floor(new Date("2022-04-14").valueOf() / 1000);

  await timelock
    .executeTransaction(
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
