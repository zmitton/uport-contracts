const Contract = require('truffle-contract')

const UportContracts = {
  ArrayLib:                       require('./build/contracts/ArrayLib.json'),
  IdentityFactory:                require('./build/contracts/IdentityFactory.json'),
  IdentityFactoryWithRecoveryKey: require('./build/contracts/IdentityFactoryWithRecoveryKey.json'),
  Migrations:                     require('./build/contracts/Migrations.json'),
  Owned:                          require('./build/contracts/Owned.json'),
  Proxy:                          require('./build/contracts/Proxy.json'),
  RecoveryQuorum:                 require('./build/contracts/RecoveryQuorum.json'),
  RecoverableController:          require('./build/contracts/RecoverableController.json'),
  RegistryV1:                     require('./build/contracts/UportRegistryV1.json'),
  RegistryV3:                     require('./build/contracts/UportRegistryV3.json')
}

module.exports = UportContracts
