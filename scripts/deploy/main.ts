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

const deployLendingContracts = async () => {
  // await deployKAP20Lending("KUSDT");
  await deployKUBLending();
  await deployKAP20Lending("KUSDC");
};

async function main() {
  // await deployYESToken();

  // await deployController();
  // await deployOracle();
  // await deployInterest();
  // await deployMarketImpl();
  // await deployVault();
  await deployLendingContracts();
  // await deployLendingContracts();

  // await deployYESLocker();
  // await deployTimelock();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
