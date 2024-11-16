
const { ethers, upgrades } = require("hardhat");
const AttesterAddress = "0xD798A4aDe873E2D447b43Af34e11882efEd911B1";

async function main() {

  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  await ethers.provider.getBalance(deployer.address).then((balance) => {
    console.log("Balance:", ethers.formatEther(balance));
  });

  const Token = await ethers.getContractFactory("MiraFilm");
//   const token = await Token.deploy();
//   await token.waitForDeployment()
  const token = Token.attach("0xa22Ba08758C024F1570AFb0a3C09461d492A5950");
  console.log("token deployed to:", await token.getAddress());

  await token.mint("0xf6e37cee1f92caf16c8c1f37a54680c87dcaf205", ethers.parseEther("1000"));


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
