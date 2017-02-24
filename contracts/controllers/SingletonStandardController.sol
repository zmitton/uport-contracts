pragma solidity 0.4.8;
import "../proxies/Proxy.sol";
import "../libraries/ProxyOwnerFinder.sol";

contract SingletonStandardController {
  uint public version;
  uint public timeLock; // 259200 == 3 days

  mapping(address => Controller) public controllers;//userKey->proxyaddress
  struct Controller{
    bool    public isInit;
    Proxy   public proxy;
    address public recovery;
    uint64  public unlockedAt; //0x0 for always locked
  }

  event RecoveryEvent(string action, address initiatedBy);
  modifier onlyRecoveryKey(userKey){ if(controllers[userKey].recovery == msg.sender)_; }
  modifier onlyUnlocked(){ if(!locked(controllers[msg.sender]) _; }

  function SingletonStandardController(uint _timeLock) {
    version = 1;
    timeLock = _timeLock;
  }
//creation
  function createController(address proxyAddress, address recovery) onlyUnlocked{
    if(msg.sender == Proxy(proxyAddress).owner()){
      _createController(msg.sender, proxyAddress, recovery);
    }
  }
  function _createController(address userKey, address proxy, address recovery) private {
    controllers[userKey] = Controller({
      isInit: true,
      proxy: Proxy(proxy), 
      recovery: recovery, //reason about: is 0x0 a safe option?
      unlockedAt: 0x0
    });
  }
  function locked(Controller id) returns(bool){
    if(id.isInit != 0x0){ //user exists
      if(id.settingsUnlocked >= now || id.settingsUnlocked == 0x0){ //settings are locked
        return true;
      }
    }
    return false;
  }
//use
  function forward(address destination, uint value, bytes data) {
    controllers[msg.sender].proxy.forward(destination, value, data);
  }
//settings
  function unlock(){
    controllers[msg.sender].unlockedAt = now + timeLock;
  }
  function lock(){
    controllers[msg.sender].unlockedAt = 0x0;
  }
  function changeController(address controller) onlyUnlocked{
    //access *is* granted to unregistered userkeys
    controllers[msg.sender].proxy.transfer(controller); //but should error here because proxy->0x0
    deleteController(controllers[msg.sender]);
  }
  function changeRecovery(address newRecovery) onlyUnlocked{ 
    controllers[msg.sender].recovery = newRecovery; 
    delete controllers[msg.sender].unlockedAt; //lock
  }
  function changeUserKey(uint8 v, bytes32 r, bytes32 s) onlyUnlocked{ 
    address newUserKey = ecrecover(bytes32(msg.sender), v, r, s); //newUserKey signs oldUserKey
    //newUserKey is 0x0 on sig failure. Do we need to protect this (zero address)?
    _createController(newUserKey, controllers[msg.sender].proxy, controllers[msg.sender].recovery)
    deleteController(controllers[msg.sender]);
  }

  function changeRecoveryFromRecovery(address userKey, address newRecovery) onlyRecoveryKey(userKey){ 
    controllers[userKey].recovery = newRecovery; //can be address of (key or contract)
    delete controllers[userKey].unlockedAt; //lock
  }
  function changeUserKeyFromRecovery(address oldUserKey, uint8 v, bytes32 r, bytes32 s) onlyRecoveryKey(oldUserKey){ 
    address newUserKey = ecrecover(bytes32(oldUserKey), v, r, s); //newUserKey signs oldUserKey, gives to delegates
    _createController(newUserKey, controllers[msg.sender].proxy, controllers[msg.sender].recovery)
    deleteController(controllers[msg.sender]);

    delete controllers[oldUserKey].unlockedAt; //lock
  }
// private
  function deleteController(Controller id) private{
    delete id.isInit;
    delete id.proxy;
    delete id.recovery;
    delete id.unlockedAt;
  }
}
