import { Interface } from "@ethersproject/abi";
import { formatEther } from "@ethersproject/units";
import { ethers, network } from "hardhat";
import { BigNumber } from '@ethersproject/bignumber';
import {
  YESController__factory, YESVault__factory, ILToken__factory,
  LKAP20__factory, LKUB, LKUB__factory, LToken, LToken__factory
} from "../../typechain";
import { LTokenInterface } from "../../typechain/LToken";
import addressUtils from "../../utils/addressUtils";

//./interfaces/ILKAP20.sol

// [lkub, ldai, lust, lbnb] =>  borrower addresses => 4 requests

// borrower 130 YES - collateral 100 -> 26 lkub, 25 ldai, 25 lust, 25 lbnb
// borrower 101.92 YES - collateral 76.44 -> 0 lkub, 25 ldai, 25 lust, 25 lbnb

// when clicking liquidate button -> call lToken.getAccountSnapshot(borrower) -> (err, lToken, borrow, exchangeRate)
// check max borrowBalance and liquidate that token

const PAGE_SIZE = 50000;

const getPastBorrowers = async (lToken: LToken, lTokenInterface: Interface, offset: number) => {
  //console.log("lTokenInterface",lTokenInterface)
  const addressList = await addressUtils.getAddressList(network.name);
  const Controller = await ethers.getContractFactory('YESController') as YESController__factory;
  const YESVault = await ethers.getContractFactory('YESVault') as YESVault__factory;

  const yesController = await Controller.attach(addressList.yesController);
  const yesVault = await YESVault.attach(addressList.yesVault);

  if (yesController && yesVault && lToken && lTokenInterface) {
    // For lenders, edit `lToken.filters.Borrow()` to `lToken.filters.Mint()`
    const filter = lToken.filters.Borrow() as any;
    const latestBlock = await ethers.provider.getBlockNumber();
    filter.toBlock = latestBlock - offset; // 200000-0
    filter.fromBlock = filter.toBlock - PAGE_SIZE; // 200000-50000

    const logs = await ethers.provider.getLogs(filter);
    //console.log("logs",logs)
    // ['0xaaa', '0xsss'] => [{wallet: '0x000', amount: '10'}]
    const borrowerAddresses = logs.map(
      (log) => lTokenInterface.parseLog(log).args[0]
    );

    // removable
    const uniqueAddresses = Array.from(new Set(borrowerAddresses));
    const promises = uniqueAddresses.map((address) =>
      lToken.getAccountSnapshot(address),
    );
    const results = await Promise.all(promises);

    const tokenName = await lToken.symbol()

    const borrowLiquidities = results.map((res, index) => {
      const [liquidity, balance, borrowBalance] = res;
      return {
        balance: Number(formatEther(borrowBalance)),
        address: uniqueAddresses[index],
        token: tokenName
      };
    });

    return { data: borrowLiquidities, hasNext: filter.fromBlock > 0 };
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
    const data = await getPastBorrowers(lToken, lTokenInterface, tmpOffset);
    results = [...results, ...data.data];
    tmpOffset += PAGE_SIZE;
    hasNext = data.hasNext;
  }
  return results;
};


async function main() {
  const addressList = await addressUtils.getAddressList(network.name);

  const ltokenInterface = await new ethers.utils.Interface(LToken__factory.abi);

  const LKUB = await ethers.getContractFactory('LKUB') as LKUB__factory;
  const lkub = await LKUB.attach(addressList.lkub);

  const LKAP20 = await ethers.getContractFactory('LKAP20') as LKAP20__factory;
  const lkbtc = await LKAP20.attach(addressList.lkbtc);
  const lketh = await LKAP20.attach(addressList.lketh);
  const lkusdt = await LKAP20.attach(addressList.lkusdt);
  const lkusdc = await LKAP20.attach(addressList.lkusdc);
  const lkdai = await LKAP20.attach(addressList.lkdai);

  //return a.balance < b.balance ? 1 : a.balance > b.balance ? -1 : 0;
  const lkubBorrowers = await getLenderTillLast(lkub, ltokenInterface, 0);
  //console.log(`KUB borrowers: `, lkubBorrowers);

  const lkbtcBorrowers = await getLenderTillLast(lkbtc, ltokenInterface, 0);
  //console.log(`KBTC borrowers: `, lkbtcBorrowers);

  const lkethBorrowers = await getLenderTillLast(lketh, ltokenInterface, 0);
  //console.log(`KETH borrowers: `, lkethBorrowers);

  const lkusdtBorrowers = await getLenderTillLast(lkusdt, ltokenInterface, 0);
  //console.log(`KUSDT borrowers: `, lkusdtBorrowers);

  const lkusdcBorrowers = await getLenderTillLast(lkusdc, ltokenInterface, 0);
  //console.log(`KUSDC borrowers: `, lkusdcBorrowers);

  const lkdaiBorrowers = await getLenderTillLast(lkdai, ltokenInterface, 0);
  //console.log(`KDAI borrowers: `, lkdaiBorrowers);

  const totalvalue =
    [
      ...lkubBorrowers, ...lkbtcBorrowers, ...lkethBorrowers,
      ...lkusdtBorrowers, ...lkusdcBorrowers, ...lkdaiBorrowers
    ]

  const result = totalvalue.reduce((acc, cur) => {
    const foundInAcc = Object.entries(acc).filter(([key]) => key === cur.address);
    if (foundInAcc) {
      acc[cur.address] = {
        ...acc[cur.address],
        [cur.token]: cur.balance,
      };
    } else {
      acc = {
        ...acc,
        [cur.address]: {
          [cur.token]: cur.balance,
        },
      };
    }
    return acc;
  }, {});
  console.log("Value Borrow ===>", result)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
