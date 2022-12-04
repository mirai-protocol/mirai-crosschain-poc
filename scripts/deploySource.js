// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const Source = await hre.ethers.getContractFactory("ESource");

  const connext = "0xA7e906b2939cb12eB46Fa00413CE695996d2B7A8";

  const SourceInstance = await Source.deploy(connext);

  console.log("Source address ", SourceInstance.address);

  await SourceInstance.deployed();

  await hre.run("verify:verify", {
    address: SourceInstance.address,
    // address: "0x105F951097ed6E7D8Bd9f81bc9A5b1BD867430F9",
    constructorArguments: [connext],
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
