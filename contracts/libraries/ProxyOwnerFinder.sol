pragma solidity 0.4.8;
import "../proxies/proxy.sol";

library ProxyOwnerFinder{
    function getProxyOwner(address _proxy) returns(address){
        return Proxy(_proxy).owner();
    }
}
