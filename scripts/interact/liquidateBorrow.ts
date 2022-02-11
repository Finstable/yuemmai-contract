import { formatEther } from "@ethersproject/units";
import { parseEther } from "ethers/lib/utils";
import hre, { ethers } from "hardhat";
import {
  KAP20Lending__factory,
  KAP20__factory,
  KUBLending__factory,
  YESController__factory,
  YESToken__factory,
  YESVault__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import timeUtils from "../../utils/timeUtils";

async function main() {
  const [owner] = await ethers.getSigners();
  //   const [, , , , owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const yes = YESToken__factory.connect(addressList["YES"], owner);
  const vault = YESVault__factory.connect(addressList["YESVault"], owner);

  const kubLending = KUBLending__factory.connect(
    addressList["KUBLending"],
    owner
  );
  const controller = YESController__factory.connect(
    addressList["YESController"],
    owner
  );
  const borrower = "0x73d8f731ec0d3945d807a904bf93954b82b0d594";

  const accountLiquidity = await controller.getAccountLiquidity(borrower);

  const data = {
    err: formatEther(accountLiquidity[0]),
    collateral: formatEther(accountLiquidity[1]),
    borrowLimit: formatEther(accountLiquidity[2]),
    borrowVal: formatEther(accountLiquidity[3]),
  };

  console.log(data);

  const input = parseEther('10');
  const minReward = 0;
  const deadline = timeUtils.now() + timeUtils.duration.days(1);

  const receipt = await kubLending
    .liquidateBorrow(input, minReward, deadline, borrower, owner.address, {
      value: input
    })
    .then((tx) => tx.wait());

  console.log(receipt.events);

  const kkub = KAP20__factory.connect(addressList["KKUB"], owner);
  console.log(
    await kkub.balanceOf(owner.address).then((res) => formatEther(res))
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
