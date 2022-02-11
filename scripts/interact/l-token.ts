import hre, { ethers } from "hardhat";
import {
  KYCBitkubChainV2__factory,
  LToken__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";

async function main() {
  const [owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const lkap20 = LToken__factory.connect(addressList["L-KUSDT"], owner);

  const kycAddr = await lkap20.kyc();
  const kyc = KYCBitkubChainV2__factory.connect(kycAddr, owner);

  const sender = "0xcdCc562088F99f221B0C3BB1EDcFD5A9646D0B25";

  console.log("Accepted level: ", await lkap20.acceptedKYCLevel());
  console.log("Sender level: ", await kyc.kycsLevel(sender));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
