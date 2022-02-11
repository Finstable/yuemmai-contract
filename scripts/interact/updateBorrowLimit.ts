import { formatEther, parseEther } from "@ethersproject/units";
import { ethers, network } from "hardhat";
import { YESController__factory, YESToken__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";

const addresses = [
  '0x041C6240a426Bcd34aE384499d0b56e1128c54DC'
];

async function main() {
  const [owner] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(network.name);

  const controller = YESController__factory.connect(
    addressList["YESController"],
    owner
  );

  const amount = parseEther("14956.625785223");

  const PAGE_SIZE = 30;

  for (let i = 0; i < Math.ceil(addresses.length / PAGE_SIZE); i++) {
    const promises = addresses
      .slice(i * PAGE_SIZE, (i + 1) * PAGE_SIZE)
      .map(async (address) => {
        return {
          borrowLimit: await controller.borrowLimitOf(address),
          address,
        };
      });

    const data = await Promise.all(promises);
    console.log(data);
    const filtered = data.filter((u) => u.borrowLimit.lt(amount));
    console.log(filtered.map((f) => f.address));

    const txCount = await owner.getTransactionCount("latest");

    const promises2 = filtered.map(async (data, index) => {
      const nonce = txCount + index;
      console.log({ nonce });
      // console.log({ borrowLimit });
      await controller
        ._setBorrowLimit(data.address, amount, {
          nonce,
        })
        .then(async (tx) => {
          await tx.wait();
          console.log("Updated: ", data.address);
        })
        .catch((e) => {
          console.error("Error: ", nonce);
        });
    });

    await Promise.all(promises2);
  }

  // for (let i = 0; i < filtered.length; i++) {
  //   const address = filtered[i].address;
  //   const borrowLimit = await controller.borrowLimitOf(address);

  //   if (borrowLimit.eq(0)) {
  //     console.log({ borrowLimit });
  //     await controller._setBorrowLimit(address, amount).then((tx) => tx.wait());
  //     console.log("Updated: ", address);
  //   }
  // }

  console.log("Done");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
