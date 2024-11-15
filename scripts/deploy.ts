import { ethers } from "hardhat";
import { MiracamNFT } from "../typechain-types";


async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  await ethers.provider.getBalance(deployer.address).then((balance) => {
    console.log("Balance:", ethers.formatEther(balance));
  });

  const nft = await ethers.deployContract("MiracamNFT", [deployer.address, deployer.address]);
  await nft.waitForDeployment();
  console.log("NFT deployed to:", await nft.getAddress());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
