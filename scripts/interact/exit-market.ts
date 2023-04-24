import hre from "hardhat";
import { YESController__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import { getSigners } from "../utils/getSigners";

const exitMarket = async () => {
  const [owner] = await getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const controller = await YESController__factory.connect(
    addressList["YESController"],
    owner
  );

  await controller
    .exitMarket(addressList["KBTCLending"])
    .then((tx) => tx.wait());

  console.log("Exit Market Success");
};

exitMarket()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
