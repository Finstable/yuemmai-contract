import hre, { ethers } from "hardhat";
import { YESVault__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";

async function main() {
  const [owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const vault = await YESVault__factory.connect(addressList["YESVault"], owner);

  const address = "0x96BB11EEb0E21A4209F6659AdE3f0ebb40202814";

  console.log("Vault token: ", await vault.tokensOf(address));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
