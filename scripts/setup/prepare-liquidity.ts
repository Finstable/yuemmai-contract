import { formatEther } from "ethers/lib/utils";
import hre from "hardhat";
import { TestKUSDT__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import { getSigners } from "../utils/getSigners";

export const prepareLiquidity = async () => {
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const [owner] = await getSigners();

  const requiredTokens = "1000000";
  const kusdt = TestKUSDT__factory.connect(addressList["KUSDT"], owner);

  await kusdt.mint(owner.address, requiredTokens).then((tx) => tx.wait());

  console.log(
    "Owner KUSDT balance: ",
    await kusdt.balanceOf(owner.address).then((res) => formatEther(res))
  );
  console.log(
    "Owner KUB balance: ",
    await owner.provider
      .getBalance(owner.address)
      .then((res) => formatEther(res))
  );
};
