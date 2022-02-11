import { formatEther, parseEther } from "ethers/lib/utils";
import hre, { ethers } from "hardhat";
import {
  KKUB__factory,
  KUBLending__factory,
  Releaser__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import timeUtils from "../../utils/timeUtils";

async function main() {
  const [, , , , superAdmin] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const kkubLending = KUBLending__factory.connect(
    addressList["KKUBLending"],
    superAdmin
  );
  const kkub = KKUB__factory.connect(addressList["KKUB"], superAdmin);

  const sender = "0xcdCc562088F99f221B0C3BB1EDcFD5A9646D0B25";
  const amount = parseEther("0.0001");

  await kkubLending
    .connect(superAdmin)
    .deposit(amount, sender)
    .then((tx) => tx.wait());

  console.log(
    "KKUB Balance: ",
    await kkub.balanceOf(sender).then((res) => formatEther(res))
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
