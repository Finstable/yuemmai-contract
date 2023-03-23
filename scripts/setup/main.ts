import { setupController } from "./setup-controller";
import { setupYESVault } from "./setup-yes-vault";
import { addSwapLiquidity } from "./add-swap-liquidity";
import { prepareLiquidity } from "./prepare-liquidity";
import { approveTokens } from "./approve-tokens";
import { checkBalances } from "./check-balances";
import { checkAllowance } from "./check-allowance";

async function main() {
  // await checkBalances();
  // await checkAllowance();
  // await prepareLiquidity();
  // await approveTokens();
  // await setupYESVault();
  // await addSwapLiquidity();
  await setupController();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
