
const { ethers, upgrades } = require("hardhat");
const AttesterAddress = "0xD798A4aDe873E2D447b43Af34e11882efEd911B1";

async function main() {

  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  await ethers.provider.getBalance(deployer.address).then((balance) => {
    console.log("Balance:", ethers.formatEther(balance));
  });


  const MiracamNFT = await ethers.getContractFactory("MiracamNFT");
  const miracamNFT = MiracamNFT.attach("0x4b79800e11fA527b01685056970D62878240Ea46");

  const Token = await ethers.getContractFactory("MiraFilm");
//   const token = await Token.deploy();
//   await token.waitForDeployment()
  const token = Token.attach("0xa22Ba08758C024F1570AFb0a3C09461d492A5950");
  console.log("token deployed to:", await token.getAddress());

  const MiracamNftMinter = await ethers.getContractFactory("MiracamNftMinter");
  const miracamNFTMinter = await upgrades.deployProxy(MiracamNftMinter, [miracamNFT.target, AttesterAddress, token.target]);
  await miracamNFTMinter.waitForDeployment();
  console.log("miracamNFTMinter deployed to:", await miracamNFTMinter.getAddress());

  const MINTER_ROLE = await miracamNFT.MINTER_ROLE()
  await miracamNFT.grantRole(MINTER_ROLE, miracamNFTMinter.target);



}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
