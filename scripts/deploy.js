const hre = require("hardhat");

async function main() {

  const HealthCare = await hre.ethers.getContractFactory("OptimizedHealthCare");

  console.log("Deploying contract...");


  const healthCare = await HealthCare.deploy();

  await healthCare.waitForDeployment();

  console.log("Contract deployed at:", await healthCare.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });