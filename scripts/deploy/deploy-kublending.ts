import hre from "hardhat";
import { KUBLending__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import { getSigners } from "../utils/getSigners";

export const deployKUBLending = async () => {
  const [owner] = await getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const KUBLending = (await hre.ethers.getContractFactory(
    "KUBLending"
  )) as KUBLending__factory;

  const exchangeRate = hre.ethers.utils.parseEther("1");
  const name = "KUB Lending Token";
  const symbol = "L-KUB";
  const decimals = 18;
  const acceptedKYCLevel = 4;

  const kubLending = await KUBLending.connect(owner).deploy({
    underlyingToken: addressList["KKUB"],
    controller: addressList["YESController"],
    interestRateModel: addressList["InterestRateModel"],
    initialExchangeRateMantissa: exchangeRate,
    beneficiary: owner.address,
    poolReserve: owner.address,
    lTokenName: name,
    lTokenSymbol: symbol,
    lTokenDecimals: decimals,
    superAdmin: owner.address,
    callHelper: addressList["YuemmaiCallHelper"],
    committee: addressList["Committee"],
    adminRouter: addressList["AdminProjectRouter"],
    transferRouter: addressList["TransferRouter"],
    kyc: addressList["KYC"],
    acceptedKYCLevel,
  });

  console.log("Deploy KUBLending success: ", kubLending.address);

  await kubLending.deployTransaction.wait();

  await addressUtils.saveAddresses(hre.network.name, {
    KUBLending: kubLending.address,
    [`L-KUB`]: await kubLending.lToken(),
  });
};
