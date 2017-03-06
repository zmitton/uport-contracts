const Contract = require('truffle-contract')

const UportContracts = {
  ArrayLib:                       Contract(require('./build/contracts/ArrayLib.json')),
  IdentityFactory:                Contract(require('./build/contracts/IdentityFactory.json')),
  Migrations:                     Contract(require('./build/contracts/Migrations.json')),
  Owned:                          Contract(require('./build/contracts/Owned.json')),
  Proxy:                          Contract(require('./build/contracts/Proxy.json')),
  RecoveryQuorum:                 Contract(require('./build/contracts/RecoveryQuorum.json')),
  StandardController:             Contract(require('./build/contracts/StandardController.json')),
  SharedController:               Contract(require('./build/contracts/SharedController.json')),
  SensuiBank:                     Contract(require('./build/contracts/SensuiBank.json')),
  RegistryV1:                     Contract(require('./build/contracts/UportRegistryV1.json')),
  RegistryV3:                     Contract(require('./build/contracts/UportRegistryV3.json'))
}

module.exports = UportContracts
