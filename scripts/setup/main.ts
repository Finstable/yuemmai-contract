import { setupController } from "./setup-controller";
import { setupLendings } from "./setup-lendings";
import { setupYESVault } from "./setup-yes-vault";
import { setupYESAdmin } from "./setup-yes-admin";
import { addSwapLiquidity } from "./add-swap-liquidity";
import { setupPriceOracle } from "./setup-price-oracle";
import { prepareLiquidity } from "./prepare-liquidity";

async function main() {
  await prepareLiquidity();

  await addSwapLiquidity();
  await setupPriceOracle();

  await setupController();
  await setupYESVault();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
