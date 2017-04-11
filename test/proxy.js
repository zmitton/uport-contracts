const lightwallet = require('eth-signer')
const Proxy = artifacts.require('Proxy')
// const TestRegistry = artifacts.require('TestRegistry')
const RegistryV3 = artifacts.require('RegistryV3')

const LOG_NUMBER_1 = 0x1234000000000000000000000000000000000000000000000000000000000000
const LOG_NUMBER_2 = 0x2345000000000000000000000000000000000000000000000000000000000000

contract('Proxy', (accounts) => {
  let proxy
  let registryV3

  before((done) => {
    // Truffle deploys contracts with accounts[0]
    Proxy.new({from: accounts[0]}).then((instance) => {
      proxy = instance
      return RegistryV3.new({from: accounts[0]})
    }).then((instance) => {
      registryV3 = instance
      done()
    }).catch(done)
  })

  it('Owner can send transaction', (done) => {
    // Encode the transaction to send to the proxy contract
    let data = '0x' + lightwallet.txutils._encodeFunctionTxData('set', ['bytes32', 'address', 'bytes32'], ['', proxy.address, LOG_NUMBER_1])
    // Send forward request from the owner
    proxy.forward(registryV3.address, 0, data, {from: accounts[0]}).then(() => {
      return registryV3.get.call('', proxy.address, proxy.address)
    }).then((regData) => {
      assert.equal(regData, LOG_NUMBER_1)
      done()
    }).catch(done)
  })

  it('Receives transaction', (done) => {
    let event = proxy.Received()
    // Encode the transaction to send to the proxy contract
    event.watch((error, result) => {
      if (error) throw Error(error)
      event.stopWatching()
      assert.equal(result.args.sender, accounts[1])
      assert.equal(result.args.value, web3.toWei('1', 'ether'))
      done()
    })
    web3.eth.sendTransaction({from: accounts[1], to: proxy.address, value: web3.toWei('1', 'ether')})
  })

  it('Event works correctly', (done) => {
    // Encode the transaction to send to the proxy contract
    let data = '0x' + lightwallet.txutils._encodeFunctionTxData('set', ['bytes32', 'address', 'bytes32'], ['', proxy.address, LOG_NUMBER_1])

    proxy.forward(registryV3.address, 0, data, {from: accounts[0]}).then((result)=>{
      assert.equal(result.logs.length, 1, "exactly one event should be logged")
      assert.equal(result.logs[0].args.destination, registryV3.address)
      assert.equal(result.logs[0].args.value, 0)
      assert.equal(result.logs[0].args.data, data)
      done()
    })
  })

  it('Non-owner can not send transaction', (done) => {
    // Encode the transaction to send to the proxy contract
    let data = '0x' + lightwallet.txutils._encodeFunctionTxData('set', ['bytes32', 'address', 'bytes32'], ['', proxy.address, LOG_NUMBER_2])
    // Send forward request from a non-owner
    proxy.forward(registryV3.address, 0, data, {from: accounts[1]}).then(() => {
      return registryV3.get.call('', proxy.address, proxy.address)
    }).then((regData) => {
      assert.notEqual(regData, LOG_NUMBER_2)
      done()
    }).catch(done)
  })

  it('Should throw if function call fails', (done) => {
    let errorThrown = false
    // Encode the transaction to send to the proxy contract
    let data = '0x' + lightwallet.txutils._encodeFunctionTxData('testThrow', [], [])
    proxy.forward(registryV3.address, 0, data, {from: accounts[0]}).catch((e) => {
      errorThrown = true
    }).then(() => {
      assert.isTrue(errorThrown, 'An error should have been thrown')
      done()
    }).catch(done)
  })
})
