import { constants } from "ethers";
import { parseEther } from "ethers/lib/utils";
import hre, { ethers } from "hardhat";
import { KAP20Lending__factory, KAP20__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";

async function main() {
  const [owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const kusdtLending = KAP20Lending__factory.connect(
    addressList["KUSDTLending"],
    owner
  );

  const sender = owner.address;

  const amount = parseEther("10");

  await kusdtLending.deposit(amount, sender).then((tx) => tx.wait());

  console.log(
    "Borrow balance: ",
    await kusdtLending.callStatic.borrowBalanceCurrent(sender)
  );

  console.log("Deposited success");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
