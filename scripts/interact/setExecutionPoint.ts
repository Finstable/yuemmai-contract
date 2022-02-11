import hre, { ethers } from "hardhat";
import { LERC20__factory, LKUB__factory } from "../../typechain";
import addressUtils from '../../utils/addressUtils';

const main = async () => {
  const [signer] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(hre.network.name);

  const lkub = await LKUB__factory.connect(addressList.lkub, signer);
  await lkub._setPoolReserveExecutionPoint("1").then(tx => tx.wait());
  console.log('lkub Set execution point to: ' + await lkub.poolReserveExecutionPoint());

  const lkbtc = await LERC20__factory.connect(addressList.lkbtc, signer);
  await lkbtc._setPoolReserveExecutionPoint("1").then(tx => tx.wait());
  console.log('lkbtc Set execution point to: ' + await lkbtc.poolReserveExecutionPoint());

  const lketh = await LERC20__factory.connect(addressList.lketh, signer);
  await lketh._setPoolReserveExecutionPoint("1").then(tx => tx.wait());
  console.log('lketh Set execution point to: ' + await lketh.poolReserveExecutionPoint());

  const lkdai = await LERC20__factory.connect(addressList.lkdai, signer);
  await lkdai._setPoolReserveExecutionPoint("1").then(tx => tx.wait());
  console.log('lkdai Set execution point to: ' + await lkdai.poolReserveExecutionPoint());

  const lkusdc = await LERC20__factory.connect(addressList.lkusdc, signer);
  await lkusdc._setPoolReserveExecutionPoint("1").then(tx => tx.wait());
  console.log('lkusdc Set execution point to: ' + await lkusdc.poolReserveExecutionPoint());

  const lkusdt = await LERC20__factory.connect(addressList.lkusdt, signer);
  await lkusdt._setPoolReserveExecutionPoint("1").then(tx => tx.wait());
  console.log('lkusdt Set execution point to: ' + await lkusdt.poolReserveExecutionPoint());

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
