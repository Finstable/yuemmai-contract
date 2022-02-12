import hre from "hardhat";
import { KAP20Lending__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import { getSigners } from "../utils/getSigners";

export const deployKAP20Lending = async (underlyingSymbol: string) => {
  const [owner] = await getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const KAP20Lending = (await hre.ethers.getContractFactory(
    "KAP20Lending"
  )) as KAP20Lending__factory;

  const exchangeRate = hre.ethers.utils.parseEther("1");
  const name = `${underlyingSymbol} Lending Token`;
  const symbol = `L-${underlyingSymbol}`;
  const decimals = 18;
  const acceptedKYCLevel = 4;

  const kap20Lending = await KAP20Lending.connect(owner).deploy({
    underlyingToken: addressList[underlyingSymbol],
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

  console.log(
    `Deploy ${underlyingSymbol} Lending success: `,
    kap20Lending.address
  );

  await kap20Lending.deployTransaction.wait();

  await addressUtils.saveAddresses(hre.network.name, {
    [`${underlyingSymbol}Lending`]: kap20Lending.address,
    [`L-${underlyingSymbol}`]: await kap20Lending.lToken(),
  });
};
