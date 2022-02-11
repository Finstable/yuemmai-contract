import hre, { ethers } from "hardhat";
import {
  KKUB__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";

async function main() {
  const [owner, , , , superAdmin] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const kkub = KKUB__factory.connect(addressList["KKUB"], owner);
  // console.log("Admin: ", await kkub.adminRouter());
  // console.log("Project: ", await kkub.PROJECT());
  console.log('Committee: ', await kkub.committee());
  await kkub.setAcceptedKycLevel(0).then(tx => tx.wait());
  console.log("KYC: ", await kkub.acceptedKYCLevel());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
