import { formatEther, formatUnits, parseEther } from "ethers/lib/utils";
import hre, { ethers } from "hardhat";
import {
  AdminProjectRouter__factory,
  AdminProject__factory,
  ERC20__factory,
  LendingContract__factory,
  SlidingWindowOracle__factory,
  YESPriceOracle__factory,
  YESVault__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";

async function main() {
  const [owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const adminProjectRouter = AdminProjectRouter__factory.connect(addressList['AdminProjectRouter'], owner);

  const adminProjectAddr = await adminProjectRouter.adminProject();

  const adminProject = AdminProject__factory.connect(
    adminProjectAddr,
    owner
  );

  const project = "yuemmai";
  const address = addressList["KUSDTLending"];

  console.log(
    "Is super admin: ",
    await adminProject.isSuperAdmin(address, project)
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
