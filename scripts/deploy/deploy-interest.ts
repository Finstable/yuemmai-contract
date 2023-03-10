import { parseEther } from "ethers/lib/utils";
import hre from "hardhat";
import { JumpRateModel__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import { getSigners } from "../utils/getSigners";

export const deployInterest = async () => {
  // const base = "0.207072885780685";
  // const multiplier = "0.0782174923623391";
  // const jumpMultiplier = "2.1209";
  // const kink = "0.8";

  // const base = "0.1655519716";
  // const multiplier = "0.09690661001";
  // const jumpMultiplier = "0";
  // const kink = "1";

  // const base = "0.063";
  // const multiplier = "0.00930000000";
  // const jumpMultiplier = "1";
  // const kink = "1";

  const base = "0";
  const multiplier = "0.06100000000";
  const jumpMultiplier = "1.154";
  const kink = "0.8";

  const [owner] = await getSigners();

  const JumpRateModel = (await hre.ethers.getContractFactory(
    "JumpRateModel"
  )) as JumpRateModel__factory;
  const interestRateModel = await JumpRateModel.connect(owner).deploy(
    parseEther(base),
    parseEther(multiplier),
    parseEther(jumpMultiplier),
    parseEther(kink)
  );
  await interestRateModel.deployTransaction.wait();

  console.log("Interest Rate Model: ", interestRateModel.address);
  await addressUtils.saveAddresses(hre.network.name, {
    InterestRateModel: interestRateModel.address,
  });
};
