import { ethers, network, upgrades } from "hardhat"
import fs from "fs"
import hre from "hardhat"

async function main() {
	console.log("Starting deployments")
	const routerAddress = "0xfb8e1c3b833f9e67a71c859a132cf783b645e436"
	const PumpFactoryAddress = "0x44E1c4fcDE5dD693AF979b1fa4E47Eb3E107aCdc";

	const PumpFactoryFactory = await ethers.getContractFactory("PumpCloneFactory");
	// const PumpFactory = await PumpFactoryFactory.deploy(routerAddress) as PumpCloneFactory;
	// await PumpFactory.waitForDeployment();
	const PumpFactory = PumpFactoryFactory.attach(PumpFactoryAddress)
	console.log("This is PumpFactory address: ", await PumpFactory.getAddress())
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error)
		process.exit(1)
	})
