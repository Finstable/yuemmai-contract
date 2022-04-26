import { formatEther, parseEther } from "ethers/lib/utils";
import hre from "hardhat";
import { TestKUSDC__factory, TestKUSDT__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import { getSigners } from "../utils/getSigners";

export const prepareLiquidity = async () => {
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const [owner, signer] = await getSigners();

  const requiredTokens = parseEther("1000000");
  const kusdt = TestKUSDT__factory.connect(addressList["KUSDT"], owner);
  const kusdc = TestKUSDC__factory.connect(addressList["KUSDC"], owner);

  await kusdt.mint(owner.address, requiredTokens).then((tx) => tx.wait());
  console.log(
    "Minted KUSDT to Owner: ",
    await kusdt.balanceOf(owner.address).then((res) => formatEther(res))
  );

  await kusdc.mint(owner.address, requiredTokens).then((tx) => tx.wait());
  console.log(
    "Minted KUSDC to Owner: ",
    await kusdc.balanceOf(owner.address).then((res) => formatEther(res))
  );

  await kusdt.mint(signer.address, requiredTokens).then((tx) => tx.wait());
  console.log(
    "Minted KUSDT to Signer: ",
    await kusdt.balanceOf(signer.address).then((res) => formatEther(res))
  );

  await kusdc.mint(signer.address, requiredTokens).then((tx) => tx.wait());
  console.log(
    "Minted KUSDC to Signer: ",
    await kusdc.balanceOf(signer.address).then((res) => formatEther(res))
  );
};
