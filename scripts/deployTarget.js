// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const Source = await hre.ethers.getContractFactory("TargetNext");

  const implementation = "0x876699e39bAA682325aDcE31e6C5EA7D257Da400";

  // const SourceInstance = await Source.deploy(implementation);

  // await SourceInstance.deployed();

  // console.log("Source address ", SourceInstance.address);

  await hre.run("verify:verify", {
    //address: SourceInstance.address,
    address: "0x79dC0C7367f5455d13f13EB6720dD7fb97042F2b",
    constructorArguments: [implementation],
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
