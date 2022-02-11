import hre from "hardhat";

export const getSigners = async () => {
  return hre.ethers.getSigners();
};
