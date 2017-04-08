const Owned = artifacts.require('Owned')

contract('Owned', (accounts) => {
  let owned

  before((done) => {
    Owned.new({from: accounts[0]}).then(instance => {
      owned = instance
      done();
    })
  })

  it('Is owned by creator', (done) => {
    owned.owner().then((returnedOwner) => {
      assert.equal(returnedOwner, accounts[0], 'Owner should be owner')
      done()
    }).catch(done)
  })

  it('Non-owner can not change owner', (done) => {
    owned.transfer(accounts[1], {from: accounts[1]}).then(() => {
      return owned.owner()
    }).then((returnedOwner) => {
      assert.equal(returnedOwner, accounts[0], 'Owner should not be changed')
      done()
    }).catch(done)
  })

  it('Owner can change owner', (done) => {
    owned.transfer(accounts[1], {from: accounts[0]}).then(() => {
      return owned.owner()
    }).then((returnedOwner) => {
      assert.equal(returnedOwner, accounts[1], 'Owner should be changed')
      done()
    }).catch(done)
  })
})
