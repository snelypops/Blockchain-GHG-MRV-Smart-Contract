import { network } from "hardhat";

const { ethers } = await network.create();

const [deployer] = await ethers.getSigners();

console.log("Deploying from:", deployer.address);

const MRVContract = await ethers.getContractFactory("MRVContract");

const mrvContract = await MRVContract.deploy();

await mrvContract.waitForDeployment();

console.log(
  "MRVContract deployed to:",
  await mrvContract.getAddress()
);