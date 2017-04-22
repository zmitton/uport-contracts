# uport-contracts

Solidity code, tests, and deployment information on the contracts used for uPort. 

Spoiler Alert the easiest way to use them is with [uport-contracts-js](https://github.com/zmitton/uport-contracts-js), which is a package that is made to work with Web3. *This* package will *only* give you access to a `json` object containing:
  - ABI Definition (sometimes called the 'json interface')
  - networks (including all deployment address!!!)
  - contract_name
  - unlinked_binary
[Browse the data](https://github.com/zmitton/uport-contracts/tree/develop/build/contracts)

Use this repo *as a package* if you need a super-light-weight thing with zero dependencies. If you *only* need the ABI definitions, and/or contract addresses, this is the package for you! (otherwise --> [uport-contracts-js](https://github.com/zmitton/uport-contracts-js))

# uPort
Please read our [Whitepaper](http://whitepaper.uport.me/uPort_whitepaper_DRAFT20161020.pdf) for information on what uPort is, and what is currently possible as far as integration.

## Contracts
This repository contains the contracts currently in use by uPort. This is also where you find the addresses of these contracts currently deployed on Ropsten and Mainnet.

### Proxy
This is the main identity contract. All your transactions are forwarded through this contract which acts as your persistent identifier.

### RecoverableController
This is a controller which plugs in to the proxy contract. It gives you the ability to have one key that can make transactions through the proxy, but can't change the owner of the proxy, and another key that acts as a recovery key that can change the owner of the proxy. This gives you the ability to store a recovery key in cold storage while you can use your main key for regular transactions. If your main key is lost you can change it using the recovery key from cold storage.

### RecoveryQuorum
This contract plugs into the RecoverableController to provide recovery with a n-of-m setup. This allows for creating recovery networks consisting of your friends.

### UportRegistry
This contract is used to store information related to your identity.

```javascript
npm install uport-contracts
```

## Contributing
Want to contribute to uport-contracts? Cool, please read our [contribution guidelines](./CONTRIBUTING.md) to get an understanding of the process we use for making changes to this repo.
