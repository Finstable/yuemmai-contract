import hre, { ethers } from "hardhat";
import {
  TestAdminKAP20Router__factory,
  TestAdminProjectRouter__factory,
  TestDiamonFactory__factory,
  TestDiamonRouter__factory,
  TestKKUB__factory,
  TestKUSDC__factory,
  TestKUSDT__factory,
  TestKYCBitkubChainV2__factory,
  TestNextTransferRouter__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";

export const deployTestKYC = async () => {
  const TestKYCBitkubChainV2 = (await ethers.getContractFactory(
    "TestKYCBitkubChainV2"
  )) as TestKYCBitkubChainV2__factory;
  const kyc = await TestKYCBitkubChainV2.deploy();
  await addressUtils.saveAddresses(hre.network.name, { KYC: kyc.address });
  await kyc.deployTransaction.wait();
  console.log("Deployed KYC at: ", kyc.address);
  return kyc;
};

export const deployTestAdminProjectRouter = async () => {
  const TestAdminProjectRouter = (await ethers.getContractFactory(
    "TestAdminProjectRouter"
  )) as TestAdminProjectRouter__factory;
  const adminProjectRouter = await TestAdminProjectRouter.deploy();
  await addressUtils.saveAddresses(hre.network.name, {
    AdminProjectRouter: adminProjectRouter.address,
  });
  await adminProjectRouter.deployTransaction.wait();
  console.log("Deployed AdminProjectRouter at: ", adminProjectRouter.address);

  return adminProjectRouter;
};

export const deployTestAdminKAP20Router = async () => {
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const acceptedKYCLevel = 0;
  const TestAdminKAP20Router = (await ethers.getContractFactory(
    "TestAdminKAP20Router"
  )) as TestAdminKAP20Router__factory;
  const adminKAP20Router = await TestAdminKAP20Router.deploy(
    addressList["AdminProjectRouter"],
    addressList["Committee"],
    addressList["KKUB"],
    addressList["KYC"],
    acceptedKYCLevel
  );
  await addressUtils.saveAddresses(hre.network.name, {
    AdminKAP20Router: adminKAP20Router.address,
  });
  await adminKAP20Router.deployTransaction.wait();
  console.log("Deployed AdminKAP20Router at: ", adminKAP20Router.address);

  return adminKAP20Router;
};

export const deployTestTransferRouter = async () => {
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const TestNextTransferRouter = (await ethers.getContractFactory(
    "TestNextTransferRouter"
  )) as TestNextTransferRouter__factory;
  const transferRouter = await TestNextTransferRouter.deploy(
    addressList["AdminProjectRouter"],
    addressList["AdminKAP20Router"],
    addressList["KKUB"],
    addressList["Committee"],
    [addressList["KUSDT"]]
  );
  await addressUtils.saveAddresses(hre.network.name, {
    TransferRouter: transferRouter.address,
  });
  await transferRouter.deployTransaction.wait();
  console.log("Deployed TransferRouter at: ", transferRouter.address);

  return transferRouter;
};

export const deployTestKKUB = async () => {
  const TestKKUB = (await ethers.getContractFactory(
    "TestKKUB"
  )) as TestKKUB__factory;
  const kkub = await TestKKUB.deploy();
  await addressUtils.saveAddresses(hre.network.name, { KKUB: kkub.address });
  await kkub.deployTransaction.wait();
  console.log("Deployed KKUB at: ", kkub.address);

  return kkub;
};

export const deployTestKUSDT = async () => {
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const TestKUSDT = (await ethers.getContractFactory(
    "TestKUSDT"
  )) as TestKUSDT__factory;
  const acceptedKYCLevel = 0;
  const kusdt = await TestKUSDT.deploy(
    addressList["AdminProjectRouter"],
    addressList["Committee"],
    addressList["KYC"],
    acceptedKYCLevel
  );
  await addressUtils.saveAddresses(hre.network.name, { KUSDT: kusdt.address });
  await kusdt.deployTransaction.wait();
  console.log("Deployed KUSDT at: ", kusdt.address);

  return kusdt;
};

export const deployTestKUSDC = async () => {
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const TestKUSDC = (await ethers.getContractFactory(
    "TestKUSDC"
  )) as TestKUSDC__factory;
  const acceptedKYCLevel = 0;
  const kusdc = await TestKUSDC.deploy(
    addressList["KYC"],
    addressList["AdminProjectRouter"],
    addressList["Committee"],
    addressList["TransferRouter"],
    acceptedKYCLevel
  );
  await addressUtils.saveAddresses(hre.network.name, { KUSDC: kusdc.address });
  await kusdc.deployTransaction.wait();
  console.log("Deployed KUSDC at: ", kusdc.address);

  return kusdc;
};

export const deployTestSwapFactory = async () => {
  const TestDiamonFactory = (await ethers.getContractFactory(
    "TestDiamonFactory"
  )) as TestDiamonFactory__factory;
  const swapFactory = await TestDiamonFactory.deploy();
  await addressUtils.saveAddresses(hre.network.name, {
    SwapFactory: swapFactory.address,
  });
  await swapFactory.deployTransaction.wait();
  console.log("Initial code hash: ", await swapFactory.INIT_CODE_PAIR_HASH());
  console.log("Deployed SwapFactory at: ", swapFactory.address);

  return swapFactory;
};

export const deployTestSwapRouter = async () => {
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const TestDiamonRouter = (await ethers.getContractFactory(
    "TestDiamonRouter"
  )) as TestDiamonRouter__factory;
  const swapRouter = await TestDiamonRouter.deploy(
    addressList["SwapFactory"],
    addressList["KKUB"]
  );
  await addressUtils.saveAddresses(hre.network.name, {
    SwapRouter: swapRouter.address,
  });
  await swapRouter.deployTransaction.wait();
  console.log("Deployed SwapRotuer at: ", swapRouter.address);
  return swapRouter;
};

export const deployTestEnv = async () => {
  //BK env
  // await deployTestKYC();
  // await deployTestAdminProjectRouter();

  // Tokens
  await deployTestKKUB();
  await deployTestKUSDT();
  await deployTestKUSDC();

  // Token admin
  await deployTestAdminKAP20Router();
  await deployTestTransferRouter();

  // AMM
  // await deployTestSwapFactory();
  // await deployTestSwapRouter();
};
