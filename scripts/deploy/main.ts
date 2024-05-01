import { deployYESToken } from "./deploy-yes-token";
import { deployController } from "./deploy-controller";
import { deployInterest } from "./deploy-interest";
import { deployMarketImpl } from "./deploy-marketImpl";
import { deployOracle } from "./deploy-oracle";
import { deployVault } from "./deploy-vault";
import { deployKAP20Lending } from "./deploy-kap20lending";
import { deployYESLocker } from "./deploy-yes-locker";
import { deployTimelock } from "./deploy-timelock";
import { deployKUBLending } from "./deploy-kublending";
import { deployYesPriceOracleV1V2 } from "./deploy-yes-priceoaclev1v2";
import { deployYesPriceOracleV1V3 } from "./deploy-yes-priceoaclev1v3";
import { deployYesPriceOracleV1V4 } from "./deploy-yes-priceoaclev1v4";

const deployLendingContracts = async () => {
  // await deployKUBLending();
  // await deployKAP20Lending("KUSDT");
  // await deployKAP20Lending("KUSDC");
  // await deployKAP20Lending("KKUB");
};

async function main() {
  // await deployYESToken();
  // await deployController();
  // await deployOracle();
  // await deployInterest();
  // await deployMarketImpl();
  // await deployVault();
  // await deployYESLocker();
  // await deployTimelock();
  // await deployLendingContracts();
  // await deployYesPriceOracleV1V2();
  // await deployYesPriceOracleV1V3();
  await deployYesPriceOracleV1V4();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
