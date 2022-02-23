import hre from "hardhat";
import { YESLocker__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";
import timeUtils from "../../utils/timeUtils";
import { getSigners } from "../utils/getSigners";

export const deployYESLocker = async () => {
  const [owner] = await getSigners();

  const addressList = await addressUtils.getAddressList(hre.network.name);

  const acceptedKYCLevel = 4;

  const startAt = Math.floor(new Date('2022-02-14').valueOf() / 1000);
  const endAt = Math.floor(new Date('2024-02-14').valueOf() / 1000);

  const YESLocker = (await hre.ethers.getContractFactory(
    "YESLocker"
  )) as YESLocker__factory;

  const yesLocker = await YESLocker.connect(owner).deploy(
    startAt,
    endAt,
    addressList["YES"],
    addressList["KYC"],
    addressList["AdminProjectRouter"],
    addressList["Committee"],
    addressList["TransferRouter"],
    acceptedKYCLevel
  );
  await yesLocker.deployTransaction.wait().then((res) => res.transactionHash);

  console.log("YESLocker Token: ", yesLocker.address);

  await addressUtils.saveAddresses(hre.network.name, {
    YESLocker: yesLocker.address,
  });
};
