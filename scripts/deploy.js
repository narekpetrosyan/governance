const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log(`Deployer: ${deployer.address}`);

  const MyToken = await hre.ethers.getContractFactory("MyToken");
  const mytoken = await MyToken.deploy();
  await mytoken.deployed();
  console.log(`MyToken deployed: ${mytoken.address}`);

  const Governance = await hre.ethers.getContractFactory("Governance");
  const govercnance = await Governance.deploy(mytoken.address);
  await govercnance.deployed();
  console.log(`Governance deployed: ${govercnance.address}`);

  const Demo = await hre.ethers.getContractFactory("Demo");
  const demo = await Demo.deploy();
  await demo.deployed();
  console.log(`Demo deployed: ${demo.address}`);

  const tx = await demo.transferOwnership(govercnance.address);
  await tx.wait();
  console.log("Ownership transferred.");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
