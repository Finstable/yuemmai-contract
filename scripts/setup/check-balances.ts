import { constants } from "ethers";
import { formatEther, parseEther } from "ethers/lib/utils";
import hre from "hardhat";
import {
  TestKUSDC__factory,
  TestKUSDT__factory,
  YESToken,
  YESToken__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import { getSigners } from "../utils/getSigners";

export const checkBalances = async () => {
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const [owner, signer] = await getSigners();

  const kusdt = TestKUSDT__factory.connect(addressList["KUSDT"], owner);
  const kusdc = TestKUSDC__factory.connect(addressList["KUSDC"], owner);
  const yesToken = YESToken__factory.connect(addressList["YES"], owner);

  // Owner
  console.log(
    "Owner YES token: ",
    await yesToken.balanceOf(owner.address).then((res) => formatEther(res))
  );

  console.log(
    "Owner KUSDT: ",
    await kusdt.balanceOf(owner.address).then((res) => formatEther(res))
  );

  console.log(
    "Owner KUSDC: ",
    await kusdc.balanceOf(owner.address).then((res) => formatEther(res))
  );

  console.log(
    "Owner KUB: ",
    await signer.provider.getBalance(owner.address).then((res) => formatEther(res))
  );

  // Signer
  console.log(
    "Signer KUSDT: ",
    await kusdt.balanceOf(signer.address).then((res) => formatEther(res))
  );

  console.log(
    "Signer KUSDC: ",
    await kusdc.balanceOf(signer.address).then((res) => formatEther(res))
  );

  console.log(
    "Signer KUB: ",
    await signer.provider.getBalance(signer.address).then((res) => formatEther(res))
  );
};
