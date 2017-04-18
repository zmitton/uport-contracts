pragma solidity ^0.4.4;
import "../controllers/RecoverableController.sol";

contract IdentityFactoryWithRecoveryKey {
    event IdentityCreated(
        address indexed userKey,
        address proxy,
        address controller,
        address indexed recoveryKey);

    function CreateProxyWithControllerAndRecoveryKey(address userKey, address _recoveryKey, uint longTimeLock, uint shortTimeLock) {
        Proxy proxy = new Proxy();
        RecoverableController controller = new RecoverableController(proxy, userKey, longTimeLock, shortTimeLock);
        proxy.transfer(controller);
        controller.changeRecoveryFromRecovery(_recoveryKey);

        IdentityCreated(userKey, proxy, controller, _recoveryKey);
    }
}
