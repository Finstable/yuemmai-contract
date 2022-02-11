import { Interface } from "@ethersproject/abi";
import { formatEther } from "@ethersproject/units";
import { ethers, network } from "hardhat";
import { YESToken, YESToken__factory} from "../../typechain";
import addressUtils from "../../utils/addressUtils";

const PAGE_SIZE = 50000;

const getPastAirdrop = async (yesToken: YESToken, yesTokenInterface: Interface, offset: number) => {
  if (yesToken && yesTokenInterface) {
    const filter = yesToken.filters.Released() as any;
    const latestBlock = await ethers.provider.getBlockNumber();
    filter.toBlock = latestBlock - offset; // 200000-0
    filter.fromBlock = filter.toBlock - PAGE_SIZE; // 200000-50000
    const logs = await ethers.provider.getLogs(filter);
    const result = logs.map(
      (log) => ({ address: yesTokenInterface.parseLog(log).args[1], amount: yesTokenInterface.parseLog(log).args[2] })
    );
    return { data: result, hasNext: filter.fromBlock > 0 };
  }
};

const getAirdropTillLast = async (
  yesToken: YESToken,
  yesTokenInterface: Interface,
  offset: number
) => {
  let hasNext = true;
  let results = [];
  let tmpOffset = offset;
  while (hasNext) {
    const data = await getPastAirdrop(yesToken, yesTokenInterface, tmpOffset);
    results = [...results, ...data.data];
    tmpOffset += PAGE_SIZE;
    hasNext = data.hasNext;
  }
  return results;
};

//formatEther
async function main() {
  const addressList = await addressUtils.getAddressList(network.name);
  const [wallet] = await ethers.getSigners()
  const yesTokenInterface = await new ethers.utils.Interface(YESToken__factory.abi);

  const yes = YESToken__factory.connect(addressList.yesToken, wallet);
  const yesAirdrop = await getAirdropTillLast(yes, yesTokenInterface, 0);
  console.log("show", yesAirdrop)

  const result = yesAirdrop.reduce((acc, cur) => {
    if (!acc[cur.address]) acc[cur.address] = 0;
    acc[cur.address] += Number(formatEther(cur.amount));
    return acc;
  }, {} as Record<string, number>);

  console.log("yesAirdrop ===>", result)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
