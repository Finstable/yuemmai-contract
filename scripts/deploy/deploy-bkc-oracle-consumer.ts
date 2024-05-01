import hre from "hardhat";
import addressUtils from "../../utils/addressUtils";
import { BKCOracleConsumer__factory } from "../../typechain";

export const deployBKCOracleConsumer = async () => {
  const [owner] = await hre.ethers.getSigners();

  const bkcOracleConsumer = (await hre.ethers.getContractFactory(
    "BKCOracleConsumer"
  )) as BKCOracleConsumer__factory;

  const BKCOracleConsumer = await bkcOracleConsumer.connect(owner).deploy();

  await BKCOracleConsumer.deployTransaction
    .wait()
    .then((res) => res.transactionHash);

  console.log("BKCOracleConsumer: ", BKCOracleConsumer.address);

  await addressUtils.saveAddresses(hre.network.name, {
    BKCOracleConsumer: BKCOracleConsumer.address,
  });
};
