import { deployYESToken } from "./deploy-yes-token";
import { deployController } from "./deploy-controller";
import { deployInterest } from "./deploy-interest";
import { deployKUBLending } from "./deploy-kublending";
import { deployMarketImpl } from "./deploy-marketImpl";
import { deployOracle } from "./deploy-oracle";
import { deployVault } from "./deploy-vault";
import { deployKAP20Lending } from "./deploy-kap20lending";
import { deployBorrowLimit } from "./deploy-borrow-limit";
import { deployYESAdmin } from "./deploy-yes-admin";
import { deployTestEnv } from "./deploy-test-env";

const deployLendingContracts = async () => {
  await deployKAP20Lending("KUSDT");
};

async function main() {
  // await deployYESToken();

  // await deployController();
  // await deployOracle();
  // await deployInterest();
  // await deployMarketImpl();
  await deployVault();
  await deployLendingContracts();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
