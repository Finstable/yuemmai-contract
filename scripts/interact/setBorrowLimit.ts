import { formatEther, parseEther } from "@ethersproject/units";
import { ethers, network } from "hardhat";
import { YESVault__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";

async function main() {
  const [owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(network.name);

  const yesVault = YESVault__factory.connect(addressList["YESVault"], owner);

  const account = "0xcdCc562088F99f221B0C3BB1EDcFD5A9646D0B25";

  const borrowLimit = parseEther("1495.6625785223");
  const amount = parseEther("10");

  await yesVault.setBorrowLimit(account, borrowLimit).then((tx) => tx.wait());
  await yesVault.airdrop(account, amount).then((tx) => tx.wait());

  console.log(
    "Borrow limit: ",
    await yesVault.borrowLimitOf(account).then((res) => formatEther(res))
  );
  console.log(
    "Airdrop: ",
    await yesVault.tokensOf(account).then((res) => formatEther(res))
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
