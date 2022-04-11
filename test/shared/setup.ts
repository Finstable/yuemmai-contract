import { constants } from "ethers";
import { parseEther } from "ethers/lib/utils";
import { ethers } from "hardhat";
import { TestKUSDT, YESToken, TestDiamonRouter, YESTicket__factory } from "../../typechain";
import timeUtils from "../../utils/timeUtils";
import {
  deployController,
  deployYESToken,
  deployJumpRateModel,
  deployMarketImpl,
  deployVault,
  deployKAP20Lending,
  deployKUBLending,
  deploySlidingWindowOracle,
  deployYesPriceOracle,
  deployTestKYC,
  deployTestAdminProjectRouter,
  deployTestAdminKAP20Router,
  deployTestKKUB,
  deployTestKUSDT,
  deployTestSwapFactory,
  deployTestSwapRouter,
  deployTestNextTransferRouter,
  deployLocker,
  deployTimelock,
} from "./deployer";

export const initialPool = {
  KUBYES: ["51136", "625000"],
  KUSDTYES: ["500000", "625000"],
};

const prepareLiquidity = async (kusdt: TestKUSDT) => {
  const [, lender, , liquidator] = await ethers.getSigners();
  await kusdt.mint(lender.address, parseEther("100000"));
  await kusdt.mint(liquidator.address, parseEther("100000"));
};

const provideLiquidity = async (
  kusdt: TestKUSDT,
  yes: YESToken,
  swapRouter: TestDiamonRouter
) => {
  const [owner] = await ethers.getSigners();

  const deadline = timeUtils.now() + timeUtils.duration.years(100);

  await kusdt.approve(swapRouter.address, constants.MaxUint256);
  await yes.approve(swapRouter.address, constants.MaxUint256);

  await swapRouter.addLiquidity(
    kusdt.address,
    yes.address,
    parseEther(initialPool["KUSDTYES"][0]),
    parseEther(initialPool["KUSDTYES"][1]),
    parseEther(initialPool["KUSDTYES"][0]),
    parseEther(initialPool["KUSDTYES"][1]),
    owner.address,
    deadline
  );

  await swapRouter.addLiquidityETH(
    yes.address,
    parseEther(initialPool["KUBYES"][1]),
    parseEther(initialPool["KUBYES"][1]),
    parseEther(initialPool["KUBYES"][0]),
    owner.address,
    deadline,
    { value: parseEther(initialPool["KUBYES"][0]) }
  );
};

// signers[0] => super admin / admin
// signers[1] => lender
// signers[2] => borrower
// signers[3] => liquidator
// signers[4] => callhelper

export const deployYESSystem = async () => {
  const signers = await ethers.getSigners();
  const owner = signers[0];
  const cHelper = signers[4];

  // BKC environment
  const committee = owner.address;
  const callHelper = cHelper.address;
  const acceptedKYCLevel = 0;

  const kyc = await deployTestKYC();
  const adminProjectRouter = await deployTestAdminProjectRouter();

  // Tokens
  const kkub = await deployTestKKUB();
  const kusdt = await deployTestKUSDT(
    adminProjectRouter.address,
    committee,
    kyc.address,
    acceptedKYCLevel
  );

  const adminKAP20Router = await deployTestAdminKAP20Router(
    adminProjectRouter.address,
    committee,
    kkub.address,
    kyc.address,
    acceptedKYCLevel
  );

  const transferRouter = await deployTestNextTransferRouter(
    adminProjectRouter.address,
    adminKAP20Router.address,
    committee,
    kkub.address,
    [kusdt.address]
  );

  // Admin setup
  const superAdmin = owner.address;
  const admin = owner.address;

  // Beneficiary setup
  const beneficiary = owner.address;
  const poolReserve = owner.address;

  // AMM
  const swapFactory = await deployTestSwapFactory();
  const swapRouter = await deployTestSwapRouter(
    swapFactory.address,
    kkub.address
  );

  // console.log("Init code hash: ", await swapFactory.INIT_CODE_PAIR_HASH());

  // Deploy system
  const controller = await deployController(owner.address);

  const totalSupply = "10000000";
  const totalAirdrop = "2500000";

  const yes = await deployYESToken(
    totalSupply,
    committee,
    adminProjectRouter.address,
    kyc.address,
    transferRouter.address,
    acceptedKYCLevel
  );

  const interest = await deployJumpRateModel();
  const marketImpl = await deployMarketImpl();
  const slidingWindowOracle = await deploySlidingWindowOracle(
    swapFactory.address
  );
  const yesPriceOracle = await deployYesPriceOracle(
    slidingWindowOracle.address,
    yes.address,
    [kusdt.address]
  );

  const pendingRelease = timeUtils.duration.years(1);

  const yesVault = await deployVault(
    controller.address,
    yes.address,
    marketImpl.address,
    swapRouter.address,
    pendingRelease,
    admin,
    superAdmin,
    committee,
    callHelper,
    transferRouter.address
  );

  const kusdtLending = await deployKAP20Lending(
    kusdt.address,
    controller.address,
    interest.address,
    "KUSDT Lending",
    "L-KUSDT",
    18,
    "1",
    beneficiary,
    poolReserve,
    superAdmin,
    callHelper,
    committee,
    adminProjectRouter.address,
    transferRouter.address,
    kyc.address,
    acceptedKYCLevel
  );

  const kubLending = await deployKUBLending(
    kkub.address,
    controller.address,
    interest.address,
    "KUB Lending",
    "L-KUB",
    18,
    "1",
    beneficiary,
    poolReserve,
    superAdmin,
    callHelper,
    committee,
    adminProjectRouter.address,
    transferRouter.address,
    kyc.address,
    acceptedKYCLevel
  );

  const startTime = timeUtils.now();
  const endTime = startTime + timeUtils.duration.days(1);

  const locker = await deployLocker(
    startTime,
    endTime,
    yes.address,
    kyc.address,
    adminProjectRouter.address,
    committee,
    transferRouter.address,
    acceptedKYCLevel
  );

  const ticketAddr = await locker.yesTicket();
  const yesTicket = YESTicket__factory.connect(ticketAddr, owner);

  // Setup Controller
  await controller.setPriceOracle(yesPriceOracle.address);

  await controller.setYESVault(yesVault.address);
  await controller.supportMarket(kubLending.address);
  await controller.supportMarket(kusdtLending.address);

  // Setup Vault
  await yes.transfer(yesVault.address, parseEther(totalAirdrop));

  // Setup liquidity
  await prepareLiquidity(kusdt);
  await provideLiquidity(kusdt, yes, swapRouter);

  // Setup oracle
  await slidingWindowOracle.update(kusdt.address, yes.address);
  await slidingWindowOracle.update(kkub.address, yes.address);
  await timeUtils.increase(timeUtils.duration.minutes(5));

  await slidingWindowOracle.update(kusdt.address, yes.address);
  await slidingWindowOracle.update(kkub.address, yes.address);

  // Setup timelock
  const timelock = await deployTimelock(owner.address, timeUtils.duration.days(1));

  return {
    // BK env
    committee,
    callHelper,
    kyc,
    adminProjectRouter,
    adminKAP20Router,
    // Admin
    superAdmin,
    admin,
    // Beneficiary
    beneficiary,
    poolReserve,
    // Tokens
    kkub,
    kusdt,
    // AMM
    swapRouter,
    swapFactory,
    // YES system
    controller,
    yes,
    interest,
    marketImpl,
    slidingWindowOracle,
    yesPriceOracle,
    yesVault,
    kusdtLending,
    kubLending,
    locker,
    yesTicket,
    timelock
  };
};

export type Contracts = Awaited<ReturnType<typeof deployYESSystem>>;
