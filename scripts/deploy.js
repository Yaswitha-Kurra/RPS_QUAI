const quais = require('quais')
const MyTokenJson = require('../artifacts/contracts/MyToken.sol/MyToken.json')
const { deployMetadata } = require("hardhat");
require('dotenv').config()

// Pull contract arguments from .env
//const tokenArgs = [process.env.ERC20_NAME, process.env.ERC20_SYMBOL, quais.parseUnits(process.env.ERC20_INITIALSUPPLY)]

async function deployRPS() {
  // Config provider, wallet, and contract factory
  const provider = new quais.JsonRpcProvider(hre.network.config.url, undefined, { usePathing: true })
  const wallet = new quais.Wallet(hre.network.config.accounts[0], provider)
  const ipfsHash = await deployMetadata.pushMetadataToIPFS("MyToken")
  const MyToken = new quais.ContractFactory(MyTokenJson.abi, MyTokenJson.bytecode, wallet, ipfsHash)

  // Broadcast deploy transaction
  const RPS_transaction = await MyToken.deploy()
  console.log('Transaction broadcasted: ', RPS_transaction.deploymentTransaction().hash)

  // Wait for contract to be deployed
  await RPS_transaction.waitForDeployment()
  console.log('Contract deployed to: ', await RPS_transaction.getAddress())
}

deployRPS()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })