const ArrayLib = artifacts.require('./libraries/ArrayLib.sol')
const IdentityFactory = artifacts.require('./factories/IdentityFactory.sol')
const IdentityFactoryWithRecoveryKey = artifacts.require('./factories/IdentityFactoryWithRecoveryKey.sol')

const RecoveryQuorum = artifacts.require('./recovery/RecoveryQuorum.sol')

module.exports = function (deployer) {
  deployer.deploy(ArrayLib)
  deployer.link(ArrayLib, [RecoveryQuorum, IdentityFactory])
  deployer.deploy(IdentityFactory)
  deployer.deploy(IdentityFactoryWithRecoveryKey)
}
