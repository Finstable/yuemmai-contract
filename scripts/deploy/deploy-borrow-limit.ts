import hre from "hardhat";
import { BorrowLimitOracle__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import { getSigners } from "../utils/getSigners";

export const deployBorrowLimit = async () => {
  const [owner] = await getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const BorrowLimitOracle = (await hre.ethers.getContractFactory(
    "BorrowLimitOracle"
  )) as BorrowLimitOracle__factory;
  const borrowLimitOracle = await BorrowLimitOracle.connect(owner).deploy(
    addressList["YESAdmin"]
  );
  await borrowLimitOracle.deployTransaction
    .wait()
    .then((res) => res.transactionHash);

  console.log("BorrowLimitOracle: ", borrowLimitOracle.address);

  await addressUtils.saveAddresses(hre.network.name, {
    BorrowLimitOracle: borrowLimitOracle.address,
  });
};
