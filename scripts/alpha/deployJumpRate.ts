import { parseEther } from "ethers/lib/utils";
import hre from "hardhat";
import { JumpRateModel__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";

async function main() {
    const base = "0.207072885780685"
    const multiplier = "0.0782174923623391" // 23-33% base APY
    const jumpMultiplier = "21.87387" // 10,000% APY maximum
    const kink = "0.8"

    const JumpRateModel = await hre.ethers.getContractFactory("JumpRateModel") as JumpRateModel__factory;
    const interestRateModel = await JumpRateModel.deploy(
        parseEther(base),
        parseEther(multiplier),
        parseEther(jumpMultiplier),
        parseEther(kink),
    );
    await interestRateModel.deployTransaction.wait();

    console.log("Interest Rate Model: ", interestRateModel.address);
    await addressUtils.saveAddresses(hre.network.name, { interestRateModel: interestRateModel.address });
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
