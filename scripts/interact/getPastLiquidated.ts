import { formatEther, formatUnits, parseEther } from "ethers/lib/utils";
import hre, { ethers } from "hardhat";
import {
  ERC20__factory,
  KUBLending__factory,
  LendingContract__factory,
  SlidingWindowOracle__factory,
  YESPriceOracle__factory,
  YESVault__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";

async function main() {
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const [owner, user] = await ethers.getSigners();

  const kubLending = KUBLending__factory.connect(
    addressList["KUBLending"],
    owner
  );

  // console.log("Balance: ", await owner.provider.getBalance(kubLending.address).then(res => formatEther(res)))
  const lendingInterface = await new ethers.utils.Interface(
    KUBLending__factory.abi
  );

  const filter = kubLending.filters.RepayBorrow() as any;
  const latestBlock = await ethers.provider.getBlockNumber();
  filter.toBlock = latestBlock;
  filter.fromBlock = 0;

  console.log({ latestBlock });

  const logs = await ethers.provider.getLogs(filter);

  console.log({logs});

  const data = logs.map((log) => lendingInterface.parseLog(log));

  console.log("Data: ", data);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
