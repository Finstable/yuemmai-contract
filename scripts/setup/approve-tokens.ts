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

export const approveTokens = async () => {
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const [owner, signer] = await getSigners();

  const kusdt = TestKUSDT__factory.connect(addressList["KUSDT"], owner);
  const kusdc = TestKUSDC__factory.connect(addressList["KUSDC"], owner);
  const yesToken = YESToken__factory.connect(addressList["YES"], owner);

  // Owner
  await yesToken
    .approve(addressList["SwapRouter"], constants.MaxUint256)
    .then((tx) => tx.wait());
  console.log(
    "Approved YES to swap router: ",
    await yesToken
      .allowance(owner.address, addressList["SwapRouter"])
      .then((res) => formatEther(res))
  );

  await kusdt
    .approve(addressList["SwapRouter"], constants.MaxUint256)
    .then((tx) => tx.wait());
  console.log(
    "Approved KUSDT to Owner: ",
    await kusdt
      .allowances(owner.address, addressList["SwapRouter"])
      .then((res) => formatEther(res))
  );

  await kusdc
    .approve(addressList["SwapRouter"], constants.MaxUint256)
    .then((tx) => tx.wait());
  console.log(
    "Approved KUSDC to Owner: ",
    await kusdc
      .allowance(owner.address, addressList["SwapRouter"])
      .then((res) => formatEther(res))
  );

  // Signer
  await kusdt
    .connect(signer)
    .approve(addressList["SwapRouter"], constants.MaxUint256)
    .then((tx) => tx.wait());
  console.log(
    "Approved KUSDT to Signer: ",
    await kusdt
      .allowances(signer.address, addressList["SwapRouter"])
      .then((res) => formatEther(res))
  );

  await kusdc
    .connect(signer)
    .approve(addressList["SwapRouter"], constants.MaxUint256)
    .then((tx) => tx.wait());
  console.log(
    "Approved KUSDC to Signer: ",
    await kusdc
      .allowance(signer.address, addressList["SwapRouter"])
      .then((res) => formatEther(res))
  );
};
