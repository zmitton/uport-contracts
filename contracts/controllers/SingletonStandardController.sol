pragma solidity 0.4.8;
import "../proxies/Proxy.sol";
import "../libraries/ProxyOwnerFinder.sol";

contract SingletonStandardController {
  uint public version;
  uint public timeLock; // 259200 == 3 days

  mapping(address => Controller) public controllers;//userKey->controller
  struct Controller{
    bool    public isInit;
    Proxy   public proxy;
    address public recovery;
    uint64  public unlockedAt; //0x0 for always locked
  }

  event RecoveryEvent(string action, address initiatedBy);
  modifier onlyRecoveryKey(userKey){ if(controllers[userKey].recovery == msg.sender)_; }
  modifier onlyUnlocked(){ if(!_locked(controllers[msg.sender]) _; }

  function SingletonStandardController(uint _timeLock) {
    version = 1;
    timeLock = _timeLock;
  }
//from userKey
  function createController(address proxyAddress, address recovery) onlyUnlocked{
    if(msg.sender == Proxy(proxyAddress).owner()){//sender controls proxy
      _createController(msg.sender, proxyAddress, recovery);//sender controls userKey
    }
  }
  function forward(address destination, uint value, bytes data) {
    controllers[msg.sender].proxy.forward(destination, value, data);
  }

  function unlock(){ controllers[msg.sender].unlockedAt = now + timeLock; }
  function lock(){ delete controllers[msg.sender].unlockedAt; }//default

  function changeController(address newController) onlyUnlocked{
    //access *is* granted to unregistered userkeys
    controllers[msg.sender].proxy.transfer(newController); //but should error here because proxy->0x0
    _deleteController(controllers[msg.sender]);
  }
  function changeRecovery(address newRecovery) onlyUnlocked{ 
    controllers[msg.sender].recovery = newRecovery; 
    delete controllers[msg.sender].unlockedAt; //lock
  }
  function changeUserKey(uint8 v, bytes32 r, bytes32 s) onlyUnlocked{//sent from oldUserKey
    _changeUserKey(msg.sender, v, r, s);
  }
//from recovery
  function changeRecoveryFromRecovery(address userKey, address newRecovery) onlyRecoveryKey(userKey){ 
    controllers[userKey].recovery = newRecovery; //can be address of (key or contract)
    delete controllers[userKey].unlockedAt; //lock
  }
  function changeUserKeyFromRecovery(address oldUserKey, uint8 v, bytes32 r, bytes32 s) onlyRecoveryKey(oldUserKey){ 
    _changeUserKey(oldUserKey, v, r, s);
  }
// private
  function _createController(address userKey, address proxy, address recovery) private {
    controllers[userKey] = Controller({
      isInit: true,
      proxy: Proxy(proxy),
      recovery: recovery, //reason about: is 0x0 a safe option?
      unlockedAt: 0x0
    });
  }
  function _changeUserKey(address oldUserKey, uint8 v, bytes32 r, bytes32 s) private{
    address newUserKey = ecrecover(bytes32(oldUserKey), v, r, s); //newUserKey signs oldUserKey, gives to delegates
    //newUserKey is 0x0 on sig failure. Do we need to protect this (zero address)?
    _createController(newUserKey, controllers[oldUserKey].proxy, controllers[oldUserKey].recovery);
    _deleteController(controllers[oldUserKey]);
  }
  function _deleteController(Controller id) private{
    delete id.isInit;
    delete id.proxy;
    delete id.recovery;
    delete id.unlockedAt;
  }
  function _locked(Controller id) returns(bool){
    if(id.isInit != 0x0){ //user exists
      if(id.settingsUnlocked >= now || id.settingsUnlocked == 0x0){ //settings are locked
        return true;
      }
    }
    return false;
  }
}
