pragma solidity 0.4.8;
import "../proxies/Proxy.sol";

contract SingletonStandardController {
  uint    public version;
  uint    public timeLock; // 259200 == 3 days

  mapping(address => Identity) public identities;//userKey->proxyaddress
  struct Identity{
    bool    hasAccess;
    Proxy   proxy;
    address public recoveryKey;
    uint64  public unlockedAt; //0x0 for always locked
  }

  event RecoveryEvent(string action, address initiatedBy);
  modifier onlyRecoveryKey(userKey){ if(identities[userKey].recoveryKey == msg.sender) _; }

  function SingletonStandardController(uint _timeLock) {
    version = 1;
    timeLock = _timeLock;
  }

  function registerProxy(address recoveryKey, uint8 v, bytes32 r, bytes32 s) { //only proxy 
    address userKey = ecrecover(bytes32(msg.sender), v, r, s);
    //userKey is 0x0 on sig failure. Do we need to protect this (zero address)?
    if(!locked(identities[userKey])){
      identities[userKey] = Identity({
        proxy: Proxy(msg.sender), 
        recoveryKey: recoveryKey, 
        unlockedAt: 0x0
      });
    }
  }

  function locked(Identity id) private returns(bool){
    if(id.userKey != 0x0){ //user exists
      if(id.settingsUnlocked >= now || id.settingsUnlocked == 0x0){ //settings are locked
        return true;
      }
    }
    return false;
  }

  function forward(address destination, uint value, bytes data) {
    identities[msg.sender].proxy.forward(destination, value, data);
  }

  function unlock(){
    identities[msg.sender].unlockedAt = now + timeLock;
  }
  function changeRecovery() { 
    identities[msg.sender].recoveryKey = recoveryKey; 
    delete identities[oldUserKey].unlockedAt;
  }
  function changeController(address controller) {
    if(!locked(identities[msg.sender])){ 
      proxy.transfer(controller); 
      delete identities[oldUserKey].unlockedAt;
    }
  }
  function changeRecoveryFromRecovery(address userKey, address newRecoveryKey) onlyRecoveryKey(userKey){ 
    identities[userKey].recoveryKey = newRecoveryKey; 
    delete identities[oldUserKey].unlockedAt;
  }
  function changeUserKeyFromRecovery(address oldUserKey, address newUserKey) onlyRecoveryKey(oldUserKey){ 
    identities[oldUserKey].userKey = newUserKey;
    delete identities[oldUserKey].unlockedAt;
  }
}

