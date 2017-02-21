pragma solidity 0.4.8;
import "../proxies/Proxy.sol";

contract SingletonStandardController {
  uint    public version;
  uint    public longTimeLock; // use 259200 for 3 days

  mapping(address => Identity) public identities;//userkey->proxyaddress
  // mapping(address => Identity) public identities;//proxyaddress->
  struct Identity{
    bool    hasAccess;
    Proxy   proxy;
    address public recoveryKey;
    uint64  public settingsUnlockedAt; //0x0 for always locked
  }

  event RecoveryEvent(string action, address initiatedBy);

  modifier onlyUserKey() { if (msg.sender == userKey) _; }
  modifier onlyRecoveryKey() { if (msg.sender == recoveryKey) _; }

  function SingletonStandardController(uint _longTimeLock) {
    version = 1;
    longTimeLock = _longTimeLock;
  }

  function registerProxy(address recoveryKey, uint8 v, bytes32 r, bytes32 s) { //only proxy 
    address userKey = ecrecover(bytes32(msg.sender), v, r, s);
    //userKey is 0x0 on sig failure. Do we need to protect this (zero address)?
    if(!locked(identities[userKey])){
      identities[userKey] = Identity({
        proxy: Proxy(msg.sender), 
        recoveryKey: recoveryKey, 
        settingsUnlockedAt: 0x0
      });
    }
  }

  function locked(Identity id) private returns(bool){
    if(id.userkey != 0x0){ //user exists
      if(id.settingsUnlocked >= now || id.settingsUnlocked == 0x0){ //settings are locked
        return true;
      }
    }
    return false;
  }

  function forward(address destination, uint value, bytes data) {
    identities[msg.sender].proxy.forward(destination, value, data);
  }

  function changeRecovery() { identities[msg.sender].recoveryKey = recoveryKey; }

  function changeController(address controller) {
   if(!locked(identities[msg.sender])){
      proxy.transfer(controller);
    }
  }
  //pass 0x0 to cancel 
  function changeUserKey(address _proposedUserKey) onlyUserKey{
    userKey = proposedUserKey;
    RecoveryEvent("changeUserKey", msg.sender);
  }

  
  function changeRecoveryFromRecovery(address _recoveryKey) onlyRecoveryKey{ recoveryKey = _recoveryKey; }
  function changeUserKeyFromRecovery(address _userKey) onlyRecoveryKey{
    delete proposedUserKey;
    userKey = _userKey;
  }
}

