var Web3 = require('web3');
var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic = require('./testMnemonics')

// var provider = new HDWalletProvider(mnemonic.ropsten, "https://infuranet.infura.io/");
// var web3 = new Web3(provider)


module.exports = {
  networks: {
    development: {
      host: 'localhost',
      port: 8546,
      network_id: '*'
    },
    ropsten: {
      host: 'localhost',
      port: 8545,
      network_id: 3,
      provider: new HDWalletProvider(mnemonic.ropsten, "https://ropsten.infura.io/")
    },
    kovan: {
      host: 'localhost',
      port: 8545,
      network_id: 42,
      gasLimit: 4712000,
      provider: new HDWalletProvider(mnemonic.kovan, "https://kovan.infura.io/")
    },
    ethereum: {
      host: 'localhost',
      port: 8545,
      network_id: 1,
      gas: 3141592
    }
  }
}
