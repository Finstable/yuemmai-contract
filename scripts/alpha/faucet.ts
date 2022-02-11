import { ethers, network } from "hardhat";
import { MintableToken__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";

//formatEther
async function main() {
    const addressList = await addressUtils.getAddressList(network.name);
    const [wallet] = await ethers.getSigners()

    const kusdt = MintableToken__factory.connect(addressList.kusdt, wallet);

    const account = '0x9B75E1E69857f2eDF8A29395AC419AdD4EdaCc67';
    const amount = '1';

    let nonce = await wallet.provider.getTransactionCount(wallet.address, 'latest');

    console.log({ nonce });

    const promises = Array.from(new Array(50)).map((_, i) => {
        console.log(`Send ${i}, nonce: ${nonce}`);
        return kusdt.mint(account, amount, { nonce: ++nonce }).then(async (tx) => {
            return tx.wait().then(() => console.log(i, tx.hash));
        })
    })

    await Promise.all(promises);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
