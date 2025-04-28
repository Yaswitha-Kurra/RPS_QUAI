const quais = require('quais')
const LotteryJson = require('../artifacts/contracts/Lottery.sol/Lottery.json')
const { deployMetadata } = require("hardhat");
require('dotenv').config()

// Pull contract arguments from .env
//const tokenArgs = [process.env.ERC20_NAME, process.env.ERC20_SYMBOL, quais.parseUnits(process.env.ERC20_INITIALSUPPLY)]

async function deployLottery() {
  // Config provider, wallet, and contract factory
  const provider = new quais.JsonRpcProvider(hre.network.config.url, undefined, { usePathing: true })
  const wallet = new quais.Wallet(hre.network.config.accounts[0], provider)
  const ipfsHash = await deployMetadata.pushMetadataToIPFS("Lottery")
  const Lottery = new quais.ContractFactory(LotteryJson.abi, LotteryJson.bytecode, wallet, ipfsHash)

  // Broadcast deploy transaction
  const Lottery_transaction = await Lottery.deploy()
  console.log('Transaction broadcasted: ', Lottery_transaction.deploymentTransaction().hash)

  // Wait for contract to be deployed
  await Lottery_transaction.waitForDeployment()
  console.log('Contract deployed to: ', await Lottery_transaction.getAddress())
}

deployLottery()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })