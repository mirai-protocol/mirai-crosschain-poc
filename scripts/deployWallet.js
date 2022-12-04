// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
 
   const Source = await hre.ethers.getContractFactory("SmartWallet");

   
const SourceInstance = await Source.deploy();

await SourceInstance.deployed();


console.log('Source address ', SourceInstance.address);

 


  await hre.run("verify:verify", {
   address: SourceInstance.address,
   //address:"0x1cE88ad8E4669783f39dddfA016163a513D23EF2",
    constructorArguments: [
      
    ]
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
