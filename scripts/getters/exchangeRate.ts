import { LendingContract__factory, LToken__factory, YESController__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import hre, { ethers } from "hardhat";
import { formatEther } from "ethers/lib/utils";

async function main() {
  const [signer] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const contract = LendingContract__factory.connect(addressList["KUSDTLending"], signer);

  console.log("exchange rate", await contract.callStatic.exchangeRateCurrent());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
