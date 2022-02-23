import { ethers } from "hardhat";
import {
  YESController__factory,
  YESToken__factory,
  SlidingWindowOracle__factory,
  YESVault__factory,
  MarketImpl__factory,
  JumpRateModel__factory,
  KUBLending__factory,
  KAP20Lending__factory,
  YESPriceOracle__factory,
  TestKYCBitkubChainV2__factory,
  TestAdminProjectRouter__factory,
  TestAdminKAP20Router__factory,
  TestKKUB__factory,
  TestKUSDT__factory,
  TestDiamonFactory__factory,
  TestDiamonRouter__factory,
  TestNextTransferRouter__factory,
  YESLocker__factory,
  Timelock__factory,
} from "../../typechain";
import timeUtils from "../../utils/timeUtils";

export const deployTestKYC = async () => {
  const TestKYCBitkubChainV2 = (await ethers.getContractFactory(
    "TestKYCBitkubChainV2"
  )) as TestKYCBitkubChainV2__factory;
  return TestKYCBitkubChainV2.deploy();
};

export const deployTestAdminProjectRouter = async () => {
  const TestAdminProjectRouter = (await ethers.getContractFactory(
    "TestAdminProjectRouter"
  )) as TestAdminProjectRouter__factory;
  return TestAdminProjectRouter.deploy();
};

export const deployTestAdminKAP20Router = async (
  adminRouter: string,
  committee: string,
  KKUB: string,
  KYC: string,
  bitkubNextLevel: number
) => {
  const TestAdminKAP20Router = (await ethers.getContractFactory(
    "TestAdminKAP20Router"
  )) as TestAdminKAP20Router__factory;
  return TestAdminKAP20Router.deploy(
    adminRouter,
    committee,
    KKUB,
    KYC,
    bitkubNextLevel
  );
};

export const deployTestNextTransferRouter = async (
  adminRouter: string,
  adminKAP20Router: string,
  committee: string,
  KKUB: string,
  kTokens: string[]
) => {
  const TestNextTransferRouter = (await ethers.getContractFactory(
    "TestNextTransferRouter"
  )) as TestNextTransferRouter__factory;
  return TestNextTransferRouter.deploy(
    adminRouter,
    adminKAP20Router,
    KKUB,
    committee,
    kTokens
  );
};

export const deployTestKKUB = async () => {
  const TestKKUB = (await ethers.getContractFactory(
    "TestKKUB"
  )) as TestKKUB__factory;
  return TestKKUB.deploy();
};

export const deployTestKUSDT = async (
  admin: string,
  committee: string,
  kyc: string,
  acceptedKYCLevel: number
) => {
  const TestKUSDT = (await ethers.getContractFactory(
    "TestKUSDT"
  )) as TestKUSDT__factory;
  return TestKUSDT.deploy(admin, committee, kyc, acceptedKYCLevel);
};

export const deployTestSwapFactory = async () => {
  const TestDiamonFactory = (await ethers.getContractFactory(
    "TestDiamonFactory"
  )) as TestDiamonFactory__factory;
  return TestDiamonFactory.deploy();
};

export const deployTestSwapRouter = async (factory: string, kkub: string) => {
  const TestDiamonRouter = (await ethers.getContractFactory(
    "TestDiamonRouter"
  )) as TestDiamonRouter__factory;
  return TestDiamonRouter.deploy(factory, kkub);
};

export const deployController = async (superAdmin: string) => {
  const YESController = (await ethers.getContractFactory(
    "YESController"
  )) as YESController__factory;
  return YESController.deploy(superAdmin);
};

export const deployYESToken = async (
  totalSupply: string = "10000000",
  committee: string,
  adminRouter: string,
  kyc: string,
  transferRouter: string,
  acceptedKYCLevel: number
) => {
  const parsedSupply = ethers.utils.parseEther(totalSupply);
  const YESToken = (await ethers.getContractFactory(
    "YESToken"
  )) as YESToken__factory;
  return YESToken.deploy(
    parsedSupply,
    kyc,
    adminRouter,
    committee,
    transferRouter,
    acceptedKYCLevel
  );
};

export const deploySlidingWindowOracle = async (
  factoryAddr: string,
  windowSize = timeUtils.duration.minutes(10),
  granularity = 2
) => {
  const SlidingWindowOracle = (await ethers.getContractFactory(
    "SlidingWindowOracle"
  )) as SlidingWindowOracle__factory;
  return SlidingWindowOracle.deploy(factoryAddr, windowSize, granularity);
};

export const deployYesPriceOracle = async (
  slidingWindowAddr: string,
  yesAddr: string,
  stableCoins: string[]
) => {
  const YESPriceOracle = (await ethers.getContractFactory(
    "YESPriceOracle"
  )) as YESPriceOracle__factory;
  return YESPriceOracle.deploy(slidingWindowAddr, yesAddr, stableCoins);
};

export const deployJumpRateModel = async (
  base = "0.207072885780685",
  multiplier = "0.0782174923623391",
  jumpMultiplier = "2.1209",
  kink = "0.8"
) => {
  const JumpRateModel = (await ethers.getContractFactory(
    "JumpRateModel"
  )) as JumpRateModel__factory;
  return JumpRateModel.deploy(
    ethers.utils.parseEther(base),
    ethers.utils.parseEther(multiplier),
    ethers.utils.parseEther(jumpMultiplier),
    ethers.utils.parseEther(kink)
  );
};

export const deployMarketImpl = async () => {
  const MarketImpl = (await ethers.getContractFactory(
    "MarketImpl"
  )) as MarketImpl__factory;
  return MarketImpl.deploy();
};

export const deployVault = async (
  controllerAddr: string,
  yesAddr: string,
  marketImplAddr: string,
  market: string,
  pendingRelease = timeUtils.duration.years(1),
  admin: string,
  superAdmin: string,
  committee: string,
  callHelper: string,
  transferRouter: string
) => {
  const YESVault = (await ethers.getContractFactory(
    "YESVault"
  )) as YESVault__factory;
  const releaseTime = (await timeUtils.latest()) + pendingRelease;

  return YESVault.deploy(
    controllerAddr,
    yesAddr,
    marketImplAddr,
    market,
    releaseTime,
    admin,
    superAdmin,
    committee,
    callHelper,
    transferRouter
  );
};

export const deployKAP20Lending = async (
  underlyingToken: string,
  controllerAddr: string,
  interestModelAddr: string,
  lTokenName: string,
  lTokenSymbol: string,
  lTokenDecimals = 18,
  exchangeRate = "1",
  beneficiary: string,
  poolReserve: string,
  superAdmin: string,
  callHelper: string,
  committee: string,
  adminRouter: string,
  transferRouter: string,
  kyc: string,
  acceptedKYCLevel: number
) => {
  const KAP20Lending = (await ethers.getContractFactory(
    "KAP20Lending"
  )) as KAP20Lending__factory;

  return KAP20Lending.deploy({
    underlyingToken,
    controller: controllerAddr,
    interestRateModel: interestModelAddr,
    initialExchangeRateMantissa: ethers.utils.parseEther(exchangeRate),
    beneficiary,
    poolReserve,
    lTokenName,
    lTokenSymbol,
    lTokenDecimals,
    superAdmin,
    callHelper,
    committee,
    adminRouter,
    transferRouter,
    kyc,
    acceptedKYCLevel,
  });
};

export const deployKUBLending = async (
  kkub: string,
  controllerAddr: string,
  interestModelAddr: string,
  lTokenName: string,
  lTokenSymbol: string,
  lTokenDecimals = 18,
  exchangeRate = "1",
  beneficiary: string,
  poolReserve: string,
  superAdmin: string,
  callHelper: string,
  committee: string,
  adminRouter: string,
  transferRouter: string,
  kyc: string,
  acceptedKYCLevel: number
) => {
  const KUBLending = (await ethers.getContractFactory(
    "KUBLending"
  )) as KUBLending__factory;
  return KUBLending.deploy({
    underlyingToken: kkub,
    controller: controllerAddr,
    interestRateModel: interestModelAddr,
    initialExchangeRateMantissa: ethers.utils.parseEther(exchangeRate),
    beneficiary,
    poolReserve,
    lTokenName,
    lTokenSymbol,
    lTokenDecimals,
    superAdmin,
    callHelper,
    committee,
    adminRouter,
    transferRouter,
    kyc,
    acceptedKYCLevel,
  });
};

export const deployLocker = async (
  startTime: number,
  endTime: number,
  yesToken: string,
  kyc: string,
  adminRouter: string,
  committee: string,
  transferRouter: string,
  acceptedKYCLevel: number
) => {
  const locker = (await ethers.getContractFactory(
    "YESLocker"
  )) as YESLocker__factory;
  return locker.deploy(
    startTime,
    endTime,
    yesToken,
    kyc,
    adminRouter,
    committee,
    transferRouter,
    acceptedKYCLevel
  );
};

export const deployTimelock = async (admin: string, delay: number) => {
  const timelock = (await ethers.getContractFactory(
    "Timelock"
  )) as Timelock__factory;
  return timelock.deploy(admin, delay);
};
