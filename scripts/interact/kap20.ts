import hre, { ethers } from "hardhat";
import {
  KAP20__factory,
  KYCBitkubChainV2__factory,
  LToken__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";

async function main() {
  const [owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const kap20 = KAP20__factory.connect(addressList["KUSDT"], owner);

  console.log("Accepted level: ", await kap20.acceptedKYCLevel());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
