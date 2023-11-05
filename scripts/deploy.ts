import { ethers, upgrades } from "hardhat";

async function main() {
  const Random = await ethers.getContractFactory("Random");
  const random = await upgrades.deployProxy(Random, []);
  await random.waitForDeployment();
  console.log("Random deployed to:", await random.getAddress());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
});