import { formatUnits, parseUnits } from "@ethersproject/units";
import { ethers, network } from "hardhat";
import { MintableToken__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";

async function main() {
  const [owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(network.name);

  const tokenAddr = addressList.kusdc;
  const amount = "1000";
  const receiver = "0xDDE97e76e584b4C97a020A86DfAd8E0e9d55d3aC";

  const token = MintableToken__factory.connect(tokenAddr, owner);
  const decimals = await token.decimals();

  console.log(
    "Pre balance: ",
    await token.balanceOf(receiver).then((res) => formatUnits(res, decimals))
  );

  await token
    .mint(receiver, parseUnits(amount, decimals))
    .then((tx) => tx.wait());

  console.log(
    "Post balance: ",
    await token.balanceOf(receiver).then((res) => formatUnits(res, decimals))
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
