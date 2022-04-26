import { formatEther, parseEther } from "@ethersproject/units";
import hre, { ethers } from "hardhat";
import { YESToken__factory, YESVault__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import { getSigners } from "../utils/getSigners";

export const setupYESVault = async () => {
  const [owner] = await getSigners();
  const totalAirdrop = parseEther("2500000");

  const addressList = await addressUtils.getAddressList(hre.network.name);

  const yesVault = YESVault__factory.connect(addressList["YESVault"], owner);
  const yes = await YESToken__factory.connect(addressList["YES"], owner);

  await yes.transfer(yesVault.address, totalAirdrop).then((tx) => tx.wait());
  console.log(
    "Initial airdrop amount: ",
    await yes.balanceOf(yesVault.address).then((res) => formatEther(res))
  );

  // WHITELIST: Bitkub add whitelist in KAP20Router
  // const adminProject = AdminProject__factory.connect(
  //   addressList["AdminProject"],
  //   owner
  // );
  // await adminProject.addSuperAdmin(yesVault.address, projectName);
  // console.log("Added vault to be a super admin");
};
