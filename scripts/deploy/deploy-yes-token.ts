import { parseEther } from "@ethersproject/units";
import hre, { ethers } from "hardhat";
import { YESToken__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import { getSigners } from "../utils/getSigners";

export const deployYESToken = async () => {
  const [owner] = await getSigners();

  const addressList = await addressUtils.getAddressList(hre.network.name);

  const totalSupply = hre.ethers.utils.parseEther("10000000");

  const acceptedKYCLevel = 4;

  const YESToken = (await hre.ethers.getContractFactory(
    "YESToken"
  )) as YESToken__factory;
  const yesToken = await YESToken.connect(owner).deploy(
    totalSupply,
    addressList["KYC"],
    addressList["AdminProjectRouter"],
    addressList["Committee"],
    addressList["TransferRouter"],
    acceptedKYCLevel
  );
  await yesToken.deployTransaction.wait().then((res) => res.transactionHash);

  console.log("YES Token: ", yesToken.address);

  await addressUtils.saveAddresses(hre.network.name, { YES: yesToken.address });
};
