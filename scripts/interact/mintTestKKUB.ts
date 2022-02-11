import { formatEther, parseEther } from "@ethersproject/units";
import { ethers, network } from "hardhat";
import {
  TestKKUB__factory,
  TestKUSDT__factory,
  YESVault__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";

async function main() {
  const [owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(network.name);

  const kkub = TestKKUB__factory.connect(addressList["KKUB"], owner);

  const account = "0xcdCc562088F99f221B0C3BB1EDcFD5A9646D0B25";

  const amount = parseEther("1");

  await kkub.deposit({ value: amount }).then((tx) => tx.wait());
  await kkub.transfer(account, amount).then((tx) => tx.wait());

  console.log(
    "KKUB Balance : ",
    await kkub.balanceOf(account).then((res) => formatEther(res))
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
