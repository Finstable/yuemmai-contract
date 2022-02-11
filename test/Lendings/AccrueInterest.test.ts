import { parseEther } from "@ethersproject/units";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Contracts, deployYESSystem } from "../shared/setup";

describe("Lending - AccrueInterest", () => {
  let contracts: Contracts;
  let senders: SignerWithAddress[];

  let borrower: SignerWithAddress;

  const utilizationRate = (cash: number, borrows: number, reserves: number) => {
    if (borrows == 0) {
      return 0;
    }
    return borrows / (cash + borrows - reserves);
  };

  const getBorrowRate = (cash: number, borrows: number, reserves: number) => {
    const blocksPerYear = 6307200;
    const kink = 0.8;
    const base = 0.207072885780685;
    const multiplier = 0.0782174923623391;
    const jumpMultiplier = 2.1209;

    const baseRatePerBlock = base / blocksPerYear;
    const multiplierPerBlock = multiplier / blocksPerYear;
    const jumpMultiplierPerBlock = jumpMultiplier / blocksPerYear;

    const util = utilizationRate(cash, borrows, reserves);

    if (util <= kink) {
      return util * multiplierPerBlock + baseRatePerBlock;
    } else {
      const normalRate = kink * multiplierPerBlock + baseRatePerBlock;
      const excessUtil = util - kink;
      return excessUtil * jumpMultiplierPerBlock + normalRate;
    }
  };

  beforeEach(async () => {
    senders = await ethers.getSigners();
    contracts = await deployYESSystem();

    borrower = senders[1];
  });

  describe("interest calculation", () => {
    it("should correctly provides borrow rate", async () => {
      const cashes = [0, 10000, 20000, 30000, 400000];
      const borrowList = [40000, 30000, 20000, 10000, 0];
      for (let i = 0; i < 5; i++) {
        const cash = cashes[i];
        const borrows = borrowList[i];
        const reserves = 0;

        const contractBorrowRate = await contracts.interest.getBorrowRate(
          parseEther(cash.toString()),
          parseEther(borrows.toString()),
          parseEther(reserves.toString())
        );
        const calBorrowRate = Math.floor(
          (await getBorrowRate(cash, borrows, reserves)) * 10 ** 18
        );

        expect(+calBorrowRate).to.be.within(
          +contractBorrowRate.sub(10),
          +contractBorrowRate.add(10)
        );
      }
    });
  });
});
