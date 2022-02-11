import { Interface } from "@ethersproject/abi";
import { formatEther } from "@ethersproject/units";
import { ethers, network } from "hardhat";
import { YESController__factory, YESVault__factory, ILToken__factory, LERC20__factory, LKUB, LKUB__factory, LToken, LToken__factory } from "../../typechain";
import { LTokenInterface } from "../../typechain/LToken";
import addressUtils from "../../utils/addressUtils";

// [lkub, ldai, lust, lbnb] =>  borrower addresses => 4 requests

// borrower 130 YES - collateral 100 -> 26 lkub, 25 ldai, 25 lust, 25 lbnb
// borrower 101.92 YES - collateral 76.44 -> 0 lkub, 25 ldai, 25 lust, 25 lbnb

// when clicking liquidate button -> call lToken.getAccountSnapshot(borrower) -> (err, lToken, borrow, exchangeRate)
// check max borrowBalance and liquidate that token

const PAGE_SIZE = 50000;

const getPastBorrowers = async (lToken: LToken, lTokenInterface: Interface, offset: number) => {
    const addressList = await addressUtils.getAddressList(network.name);
    const Controller = await ethers.getContractFactory('YESController') as YESController__factory;
    const YESVault = await ethers.getContractFactory('YESVault') as YESVault__factory;

    const yesController = await Controller.attach(addressList.yesController);
    const yesVault = await YESVault.attach(addressList.yesVault);

    if (yesController && yesVault &&  lToken && lTokenInterface) {
      // For lenders, edit `lToken.filters.Borrow()` to `lToken.filters.Mint()`
      const filter = lToken.filters.Borrow() as any;
      const latestBlock = await ethers.provider.getBlockNumber();
      filter.toBlock = latestBlock - offset;
      filter.fromBlock = filter.toBlock - PAGE_SIZE;
  
      const logs = await ethers.provider.getLogs(filter);
      // ['0xaaa', '0xsss'] => [{wallet: '0x000', amount: '10'}]
      const borrowerAddresses = logs.map(
        (log) => lTokenInterface.parseLog(log).args[0]
      );

      // removable
      const uniqueAddresses = Array.from(new Set(borrowerAddresses));
      const promises = uniqueAddresses.map((address) =>
        Promise.all([
          yesController.getAccountLiquidity(address),
          lToken.borrowBalanceStored(address),
          yesVault.tokensOf(address)
        ])
      );
      const results = await Promise.all(promises);

      const tokenName = await lToken.symbol()
  
      const borrowLiquidities = results.map((res, index) => {
        const [liquidity, borrowing, vault] = res;
        const collateralValue = formatEther(liquidity[1]);
        const borrowLimit = formatEther(liquidity[2]);
        const borrowValue = formatEther(liquidity[3]);
  
        const borrowPower = Math.min(+collateralValue, +borrowLimit);
        const shortfall = borrowPower - Number(borrowValue);
  
        return {
          collateralValue,
          borrowLimit,
          borrowValue,
          borrowPower,
          shortfall,
          borrowing: formatEther(borrowing),
          vault: formatEther(vault),
          address: uniqueAddresses[index],
          token: tokenName
        };
      });
  
      return { data: borrowLiquidities, hasNext: filter.fromBlock > 0 };
    }
  };


async function main() {
    const addressList = await addressUtils.getAddressList(network.name);

    const ltokenInterface = await new ethers.utils.Interface(LToken__factory.abi);

    const LKUB = await ethers.getContractFactory('LKUB') as LKUB__factory;
    const lkub = await LKUB.attach(addressList.lkub);

    const LERC20 = await ethers.getContractFactory('LERC20') as LERC20__factory;
    const lkbtc = await LERC20.attach(addressList.lkbtc);
    const lketh = await LERC20.attach(addressList.lketh);
    const lkusdt = await LERC20.attach(addressList.lkusdt);
    const lkusdc = await LERC20.attach(addressList.lkusdc);
    const lkdai = await LERC20.attach(addressList.lkdai);

    const lkubBorrowers = await getPastBorrowers(lkub, ltokenInterface, 0);
    console.log(`KUB borrowers: `, lkubBorrowers);

    const lkbtcBorrowers = await getPastBorrowers(lkbtc, ltokenInterface, 0);
    console.log(`KBTC borrowers: `, lkbtcBorrowers);

    const lkethBorrowers = await getPastBorrowers(lketh, ltokenInterface, 0);
    console.log(`KETH borrowers: `, lkethBorrowers);

    const lkusdtBorrowers = await getPastBorrowers(lkusdt, ltokenInterface, 0);
    console.log(`KUSDT borrowers: `, lkusdtBorrowers);

    const lkusdcBorrowers = await getPastBorrowers(lkusdc, ltokenInterface, 0);
    console.log(`KUSDC borrowers: `, lkusdcBorrowers);

    const lkdaiBorrowers = await getPastBorrowers(lkdai, ltokenInterface, 0);
    console.log(`KDAI borrowers: `, lkdaiBorrowers);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
