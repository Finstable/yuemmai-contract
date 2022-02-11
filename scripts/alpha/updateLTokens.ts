import { parseEther } from "@ethersproject/units";
import hre, { ethers } from "hardhat";
import { LKAP20__factory, LKUB__factory, LToken } from "../../typechain";
import addressUtils from "../../utils/addressUtils";

const setupLToken = async (ltoken: LToken) => {
    const [owner] = await ethers.getSigners();
    const symbol = await ltoken.symbol();
    console.log(`Setup ${symbol}`);

    const addressList = await addressUtils.getAddressList(hre.network.name);

    await ltoken._setInterestRateModel(addressList.interestRateModel).then(tx => tx.wait());

    // await ltoken._setBeneficiary(owner.address).then(tx => tx.wait());
    // console.log(`Set beneficiary to: `, owner.address);

    // await ltoken._setPlatformReserveFactor(parseEther("0.1")).then(tx => tx.wait());; // 10%
    // console.log(`Set platform reserve factor`);
    // await ltoken._setPlatformReserveExecutionPoint(parseEther('1000')).then(tx => tx.wait());;
    // console.log(`Set platform reserve execution point `);

    // await ltoken._setPoolReserveFactor(parseEther("0.1")).then(tx => tx.wait());; // 10%
    // console.log(`Set pool reserve factor`);
    // await ltoken._setPoolReserveExecutionPoint(parseEther('1000')).then(tx => tx.wait());;
    // console.log(`Set pool reserve execution point`);
}

const main = async () => {
    const addressList = await addressUtils.getAddressList(hre.network.name);

    const LKAP20 = await hre.ethers.getContractFactory('LKAP20') as LKAP20__factory;
    const LKUB = await hre.ethers.getContractFactory('LKUB') as LKUB__factory;

    const lkbtc = await LKAP20.attach(addressList.lkbtc);
    const lketh = await LKAP20.attach(addressList.lketh);
    const lkdai = await LKAP20.attach(addressList.lkdai);
    const lkusdt = await LKAP20.attach(addressList.lkusdt);
    const lkusdc = await LKAP20.attach(addressList.lkusdc);
    const lkub = await LKUB.attach(addressList.lkub);

    await setupLToken(lkbtc);
    await setupLToken(lketh);
    await setupLToken(lkdai);
    await setupLToken(lkusdt);
    await setupLToken(lkusdc);
    await setupLToken(lkub);
}


main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
