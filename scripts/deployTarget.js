// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const Source = await hre.ethers.getContractFactory("TargetNext");
  const Esource = "0x9Ad7e36569824Cdfd1e4E356436e8Ce756580F46";
  const Dsource = "0x1dce3F9a3E006475a0930CF338D3795EEa6b7f9b";

  const implementation = "0x5EB52070e7A8B4fEFdC9541d2008822C54D022C9";

  // const SourceInstance = await Source.deploy(implementation, Esource, Dsource);

  // await SourceInstance.deployed();

  // console.log("Source address ", SourceInstance.address);

  await hre.run("verify:verify", {
    //address: SourceInstance.address,
    address: "0x6459c5DD711b10524Ad77559793158ea5AcC980F",
    constructorArguments: [implementation, Esource, Dsource],
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
