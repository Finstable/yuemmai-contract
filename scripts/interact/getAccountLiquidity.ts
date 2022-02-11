import { formatEther, parseEther } from "@ethersproject/units";
import { ethers, network } from "hardhat";
import {
  KUBLending__factory,
  YESController__factory,
  YESToken__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";

async function main() {
  const [owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(network.name);

  const address = "0x5ebaddf71482d40044391923be1fc42938129988";

  const controller = YESController__factory.connect(
    addressList["YESController"],
    owner
  );

  const accountLiquidity = await controller.getAccountLiquidity(address);

  console.log({
    err: formatEther(accountLiquidity[0]),
    collateralValue: formatEther(accountLiquidity[1]),
    borrowLimit: formatEther(accountLiquidity[2]),
    borrowValue: formatEther(accountLiquidity[3]),
  });
  console.log(await controller.yesVault());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
