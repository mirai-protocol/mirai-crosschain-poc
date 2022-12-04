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
  // const connext ="0x99A784d082476E551E5fc918ce3d849f2b8e89B6";
  // const connextT = "0x173d82FF0294d4bb83A3AAF30Be958Cbc6D809f7";

  const source = "0xBF7f531f069C7a95280Fe3B04e1A5Fe010d873Fb";

  const SourceInstance = await Source.deploy(connext);

  console.log("Source address ", SourceInstance.address);

  await SourceInstance.deployed();

  await hre.run("verify:verify", {
    address: SourceInstance.address,
    //address: "0x6AabA3a532F7864876806F96Ce96A9118a013Df5",
    constructorArguments: [connext],
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
