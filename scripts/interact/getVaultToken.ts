import { formatUnits } from "@ethersproject/units";
import hre, { ethers } from "hardhat";
import { ERC20__factory, YESVault, YESVault__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";

async function main() {
  const [owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const vault = await YESVault__factory.connect(addressList["YESVault"], owner);

  const address = owner.address;

  console.log("Vault token: ", await vault.tokensOf(address));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
