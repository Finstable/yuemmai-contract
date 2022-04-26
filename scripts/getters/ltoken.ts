import { LToken__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import hre, { ethers } from "hardhat";
import { formatEther } from "ethers/lib/utils";

async function main() {
  const [signer] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const lkub = LToken__factory.connect(addressList["L-KUB"], signer);

  console.log("KYC Level", await lkub.acceptedKYCLevel());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
