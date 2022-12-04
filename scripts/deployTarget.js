// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const Source = await hre.ethers.getContractFactory("TargetNext");
  const Esource = "0x999fE6E9F5776d9C1d434f8A42D43fFf97658964";
  const Dsource = "0xb7169aAfA5d5C4301D2289FAC0C40eb6243ab1a8";

  const implementation = "0xE3C824378c5124A292c20679fFEA3abF610fa1d3";

  // const SourceInstance = await Source.deploy(implementation, Esource, Dsource);

  // await SourceInstance.deployed();

  // console.log("Source address ", SourceInstance.address);

  await hre.run("verify:verify", {
    // address: SourceInstance.address,
    address: "0x4836966fa10A5DD930c9a4BcA62873b25757619d",
    constructorArguments: [implementation, Esource, Dsource],
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
