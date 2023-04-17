import hre, { ethers } from "hardhat";
// import { LiquidateV1__factory} from "../../typechain";
import { LiquidateV1__factory } from "../../typechain-types/factories/LiquidateV1__factory";
import { getSigners } from "../utils/getSigners";

export const deployLiquidateV1 = async () => {
  const [owner] = await getSigners();
  const KUBLending = "0x74295c7cEBAccA4c25b44112Eb110643e09e15D6";
  const toSwap = "0x93185406138Cf62294A18Fb2B553464E65962a2C";
  const _SwapFactory = "0x8B7345878E2a6fEe96C973E7E7D7A376E41951d4";
  const LiquidateV1 = (await hre.ethers.getContractFactory(
    "LiquidateV1"
  )) as LiquidateV1__factory;
  const liquidateV1 = await LiquidateV1.connect(owner).deploy(
    `${KUBLending}`,
    `${toSwap}`,
    `${_SwapFactory}`
  );
  await liquidateV1.deployTransaction.wait();
  console.log("LiquidateV1: ", liquidateV1.address);
};

deployLiquidateV1()
  .then(() => process.exit(0))
  .catch((e) => {
    console.log(e);
    process.exit(1);
  });
