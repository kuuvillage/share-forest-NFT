import hre from "hardhat";

async function main() {
  const membership = await hre.viem.deployContract("Membership");
  console.log(`Contract deployed to ${membership.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
