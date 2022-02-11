import { formatEther, parseEther } from "ethers/lib/utils";
import hre, { ethers } from "hardhat";
import { YESToken__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";

const main = async () => {
  const [owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const yes = await YESToken__factory.connect(addressList["YES"], owner);

  const account = "0xc27DfEbC7d7d8fb6583b28b57541aADAf1417f40";
  const amount = parseEther("1000000");

  await yes.transfer(account, amount).then((tx) => tx.wait());

  console.log(
    "Receiver balance: ",
    await yes.balanceOf(account).then((res) => formatEther(res))
  );
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
