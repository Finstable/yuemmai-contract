import { ethers } from "hardhat";
import { DiamonPair__factory } from "../../typechain";

async function main() {
  const [owner] = await ethers.getSigners();

  const pair = await DiamonPair__factory.connect(
    "0x833e7a2E986d38D027c824Bc258C2156BE4adFFE",
    owner
  );

  const pairInterface = new ethers.utils.Interface(DiamonPair__factory.abi);

  const filter = pair.filters.Sync() as any;

  const latestBlock = await ethers.provider.getBlockNumber();
  filter.toBlock = latestBlock;
  filter.fromBlock = latestBlock - 10;

  const logs = await ethers.provider.getLogs(filter);
  const passSyncData = logs.forEach((log) => {
    console.log("Log", log);
    console.log("parsed log", pairInterface.parseLog(log));
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
