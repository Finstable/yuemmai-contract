import { setupController } from "./setup-controller";
import { setupYESVault } from "./setup-yes-vault";
import { addSwapLiquidity } from "./add-swap-liquidity";
import { prepareLiquidity } from "./prepare-liquidity";

async function main() {
  await prepareLiquidity();
  await addSwapLiquidity();

  await setupController();
  await setupYESVault();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
