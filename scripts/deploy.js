var { ethers } = require("hardhat");

async function main() {
}

async function deployHTKN() {
    var HabilidashContract = await ethers.deployContract("HabilidashTkn", []);
  var AddressContract = await HabilidashContract.getAddress();
  console.log(`Address Contract Habilidash ${AddressContract}`);
  var res = await HabilidashContract.waitForDeployment();
  await res.deploymentTransaction().wait(10);

  await hre.run("verify:verify", {
    address: AddressContract,
    constructorArguments: [],
    contract: "contracts/HTKN.sol:HabilidashTkn",
  });
}
async function deployLTKN() {
    var HabilidashLoyaltyContract = await ethers.deployContract("LoyaltyTkn", []);
    var AddressContract = await HabilidashLoyaltyContract.getAddress();
    console.log(`Address Contract Habilidash Loyalty ${AddressContract}`);
    var res = await HabilidashLoyaltyContract.waitForDeployment();
    await res.deploymentTransaction().wait(10);

  await hre.run("verify:verify", {
    address: AddressContract,
    constructorArguments: [],
    contract: "contracts/LTKN.sol:LoyaltyTkn",
  });
}
async function deployDashSupreme() {
    var contratoNft = await ethers.deployContract("DashSupreme", []);
    var contratoAddress = await contratoNft.getAddress();
    console.log(`Address Contrato es ${contratoAddress}`);
    
    // Esperar una cantidad N de confirmaciones
    var res = await contratoNft.waitForDeployment();
    await res.deploymentTransaction().wait(10);
    
    await hre.run("verify:verify", {
        address: contratoAddress,
        constructorArguments: [],
        contract: "contracts/DashSupreme.sol:DashSupreme",
    });
}
async function deployDashVerification() {
    var contratoNft = await ethers.deployContract("DashVerification", []);
    var contratoAddress = await contratoNft.getAddress();
    console.log(`Address Contrato es ${contratoAddress}`);
    
    // Esperar una cantidad N de confirmaciones
    var res = await contratoNft.waitForDeployment();
    await res.deploymentTransaction().wait(10);
    
    await hre.run("verify:verify", {
        address: contratoAddress,
        constructorArguments: [],
        contract: "contracts/Verification.sol:DashVerification",
    });
}
// main();
// deployHTKN();
// deployLTKN();
// deployDashSupreme();
deployDashVerification();
