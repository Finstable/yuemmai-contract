import { formatEther } from "ethers/lib/utils";
import hre, { ethers } from "hardhat";
import {
  DiamonPair__factory,
  TestDiamonFactory__factory,
  YESVault__factory,
} from "../../typechain";
import { YESVaultInterface } from "../../typechain/YESVault";
import addressUtils from "../../utils/addressUtils";
import * as fs from "fs";
import * as csv from "fast-csv";

const DEPLOY_BLOCK = 4748679;

async function main() {
  const [owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const factory = TestDiamonFactory__factory.connect(
    addressList["SwapFactory"],
    owner
  );

  const pairKKUBYESAddr = await factory.getPair(
    addressList["KKUB"],
    addressList["YES"]
  );
  const pairKKUBYES = DiamonPair__factory.connect(pairKKUBYESAddr, owner);
  console.log("Fee 100: ", await pairKKUBYES.fee100());

  const pairKUSDTYESAddr = await factory.getPair(
    addressList["KUSDT"],
    addressList["YES"]
  );
  const pairKUSDTYES = DiamonPair__factory.connect(pairKUSDTYESAddr, owner);
  console.log("Fee 100: ", await pairKUSDTYES.fee100());

  const pairKUSDCYESAddr = await factory.getPair(
    addressList["KUSDC"],
    addressList["YES"]
  );
  const pairKUSDCYES = DiamonPair__factory.connect(pairKUSDCYESAddr, owner);
  console.log("Fee 100: ", await pairKUSDCYES.fee100());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
