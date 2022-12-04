// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const Source = await hre.ethers.getContractFactory("TargetNext");
  const Esource = "0x5d0DD2FB435e4c52B9CcBdb29D10334383a6aB0B";
  const Dsource = "0xdf4C869AafC93dC850d7070216Fd873E804B4eD6";

  const implementation = "0x5EB52070e7A8B4fEFdC9541d2008822C54D022C9";

  // const SourceInstance = await Source.deploy(implementation, Esource, Dsource);

  // await SourceInstance.deployed();

  // console.log("Source address ", SourceInstance.address);

  await hre.run("verify:verify", {
    //address: SourceInstance.address,
    address: "0x8211dF07FEbB1607d4327dE409658b5Eb3e36f47",
    constructorArguments: [implementation, Esource, Dsource],
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
