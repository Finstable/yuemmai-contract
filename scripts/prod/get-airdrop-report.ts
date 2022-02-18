import { formatEther } from "ethers/lib/utils";
import hre, { ethers } from "hardhat";
import { YESVault__factory } from "../../typechain";
import { YESVaultInterface } from "../../typechain/YESVault";
import addressUtils from "../../utils/addressUtils";
import * as fs from "fs";
import * as csv from "fast-csv";

const DEPLOY_BLOCK = 4748679;
const FROM = 4748679;
const TO = FROM

async function main() {
  const [owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const vault = YESVault__factory.connect(addressList["YESVault"], owner);
  const ifaceVault = new ethers.utils.Interface(
    YESVault__factory.abi
  ) as YESVaultInterface;

  const filter = vault.filters.Airdrop() as any;
  // const latestBlock = await ethers.provider.getBlockNumber();
  filter.fromBlock = FROM;
  filter.toBlock = TO;

  const logs = await ethers.provider.getLogs(filter);
  const promises = logs.map(async (log) => {
    const blockNumber = log.blockNumber;
    const [beneficiary, amount] = ifaceVault.parseLog(log).args;
    const block = await ethers.provider.getBlock(blockNumber);
    const timestamp = block.timestamp * 1000;
    const date = new Date(timestamp);
    return { date, blockNumber, beneficiary, amount: formatEther(amount) };
  });

  const results = await Promise.all(promises);

  const csvStream = csv.format({ headers: true });

  let out = "";

  csvStream.on("data", (data) => {
    out += data;
  });

  results.forEach((result) => {
    csvStream.write(result);
  });

  fs.writeFileSync(`${__dirname}/../../reports/airdrop${FROM}-${TO}.csv`, out);

  csvStream.end();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
