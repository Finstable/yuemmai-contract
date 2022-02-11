import { Interface } from "@ethersproject/abi";
import { formatEther } from "@ethersproject/units";
import { ethers, network } from "hardhat";
import {
  LKAP20__factory,
  LKUB__factory,
  LToken,
  LToken__factory,
} from "../../typechain";
import addressUtils from "../../utils/addressUtils";

const PAGE_SIZE = 50000;

const getPastLenders = async (
  lToken: LToken,
  lTokenInterface: Interface,
  offset: number
) => {
  if (lToken && lTokenInterface) {
    const filter = lToken.filters.Mint() as any;
    const latestBlock = await ethers.provider.getBlockNumber();
    filter.toBlock = latestBlock - offset;
    filter.fromBlock = filter.toBlock - PAGE_SIZE;

    const logs = await ethers.provider.getLogs(filter);
    const lenderAddresses = logs.map(
      (log) => lTokenInterface.parseLog(log).args[0]
    );
    const uniqueAddresses = Array.from(new Set(lenderAddresses));

    const promises = uniqueAddresses.map((address) =>
      Promise.all([lToken.balanceOf(address)])
    );

    const results = await Promise.all(promises);

    const tokenName = await lToken.symbol();

    const lenderResult = results.map((res, index) => {
      const [balance] = res;

      return {
        balance: formatEther(balance),
        address: uniqueAddresses[index],
        token: tokenName,
      };
    });

    return { data: lenderResult, hasNext: filter.fromBlock > 0 };
  }
};

const getLenderTillLast = async (
  lToken: LToken,
  lTokenInterface: Interface,
  offset: number
) => {
  let hasNext = true;
  let results = [];
  let tmpOffset = offset;
  while (hasNext) {
    const data = await getPastLenders(lToken, lTokenInterface, tmpOffset);
    results = [...results, ...data.data];
    tmpOffset += PAGE_SIZE;
    hasNext = data.hasNext;
  }
  return results;
};

async function main() {
  const addressList = await addressUtils.getAddressList(network.name);
  const ltokenInterface = new ethers.utils.Interface(LToken__factory.abi);

  const LKUB = (await ethers.getContractFactory("LKUB")) as LKUB__factory;
  const lkub = LKUB.attach(addressList.lkub);

  const LKAP20 = (await ethers.getContractFactory("LKAP20")) as LKAP20__factory;
  const lkbtc = LKAP20.attach(addressList.lkbtc);
  const lketh = LKAP20.attach(addressList.lketh);
  const lkusdt = LKAP20.attach(addressList.lkusdt);
  const lkusdc = LKAP20.attach(addressList.lkusdc);
  const lkdai = LKAP20.attach(addressList.lkdai);

  //All Kub Lenders
  const lkubLenders = await getLenderTillLast(lkub, ltokenInterface, 0);
  console.log(
    `All KUB lenders HIGH to LOW : `,
    lkubLenders.sort((a, b) => b.balance - a.balance)
  );

  //All Btc Lenders
  const lkbtcLenders = await getLenderTillLast(lkbtc, ltokenInterface, 0);
  console.log(
    `KBTC lenders HIGH to LOW : `,
    lkbtcLenders.sort((a, b) => b.balance - a.balance)
  );

  //All Eth Lenders
  const lkethLenders = await getLenderTillLast(lketh, ltokenInterface, 0);
  console.log(
    `All KETH lenders HIGH to LOW : `,
    lkethLenders.sort((a, b) => b.balance - a.balance)
  );

  //All Usdt Lenders
  const lkusdtLenders = await getLenderTillLast(lkusdt, ltokenInterface, 0);
  console.log(
    `All KUSDT lenders HIGH to LOW : `,
    lkusdtLenders.sort((a, b) => b.balance - a.balance)
  );

  //All Usdc Lenders
  const lkusdcLenders = await getLenderTillLast(lkusdc, ltokenInterface, 0);
  console.log(
    `All KUSDC lenders HIGH to LOW : `,
    lkusdcLenders.sort((a, b) => b.balance - a.balance)
  );

  //All Dai lenders
  const lkdaiLenders = await getLenderTillLast(lkdai, ltokenInterface, 0);
  console.log(
    `All KDAI lenders HIGH to LOW : `,
    lkdaiLenders.sort((a, b) => b.balance - a.balance)
  );

  //All Lenders Data
  const lenders = [
    lkubLenders,
    lkbtcLenders,
    lkethLenders,
    lkusdtLenders,
    lkusdcLenders,
    lkdaiLenders,
  ].reduce((prev, curr) => {
    curr.forEach((e) => {
      prev[e.address] = {
        ...prev[e.address],
        [e.token]: e.balance,
      };
    });
    return prev;
  }, {});

  console.log(`All lenders Data : `, lenders);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
