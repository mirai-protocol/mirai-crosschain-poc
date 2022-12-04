// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const Source = await hre.ethers.getContractFactory("TargetNext");
  const Esource = "0x3f45c7e5C2A9fd43dbcb3d57d922CCDF8dbC4456";
  const Dsource = "0x113E0A3A68088Ae585C3E5E21AdADFc993A60685";

  const implementation = "0x5EB52070e7A8B4fEFdC9541d2008822C54D022C9";

  const SourceInstance = await Source.deploy(implementation, Esource, Dsource);

  await SourceInstance.deployed();

  console.log("Source address ", SourceInstance.address);

  await hre.run("verify:verify", {
    address: SourceInstance.address,
    // address: "0xD68C40a52Da7c090CdC5421216F372C2Da802231",
    constructorArguments: [implementation, Esource, Dsource],
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
