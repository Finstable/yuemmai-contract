import hre, { ethers } from "hardhat";
import addressUtils from "../../utils/addressUtils";
import { BKCOracleConsumer__factory } from "../../typechain";

// Note: this contract requires subscription using KDEV token. If it doesn't work, we'll need to check the subscription https://www.bkcoracle.com/datafeed/view/1.
// As of May 1st, 2024, YESAdminV1 (0xec4247Cbbbcd3aCbb0f2d91E645013730ceFad5C) controls the subscription.
async function main() {
  const addressList = await addressUtils.getAddressList(hre.network.name);
  const [owner] = await hre.ethers.getSigners();

  const bkcOracleConsumer = BKCOracleConsumer__factory.connect(
    addressList["BKCOracleConsumer"],
    owner
  );

  // Aggregator contract address. See the full list here: https://docs.bkcoracle.com/utilities/contract-addresses/bitkub-mainnet.
  const btcAggregator = "0xe937651673adCc0585254014A711542bF53fc247";

  const latestRoundData = await bkcOracleConsumer.latestRoundData(btcAggregator);

  console.log(`BTC/USDT reported by oracle is ${ethers.utils.formatUnits(latestRoundData.answer, 8)}`)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
