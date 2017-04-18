// VERSION 1
// pragma solidity 0.4.9;
// import "../libraries/Owned.sol";
// contract Proxy is Owned {
//   event Forwarded (address indexed destination, uint value, bytes data );

//   function () payable {}

//   function forward(address destination, uint value, bytes data) onlyOwner {
//     if (!destination.call.value(value)(data)) { throw; }
//     Forwarded(destination, value, data);
//   }
// }

// // VERSION 2
// pragma solidity 0.4.8;
// import "../libraries/Owned.sol";
// contract Proxy is Owned {
//   event Forwarded (address indexed destination, uint value, bytes data );
//   event Received (address indexed sender, uint value);

//   function () payable { Received(msg.sender, msg.value); }

//   function forward(address destination, uint value, bytes data) onlyOwner {
//     if (!destination.call.value(value)(data)) { throw; }
//     Forwarded(destination, value, data);
//   }
// }

// 'VERSION 3'  This proxy can create arbitrary contracts
// This is useful when the contract to be created initializes an 
// 'owner' variable, to the msg.sender.

// In order to create a contract through the proxy the forward function
// is called but with a very specific destination address.
// The destination address could have been defined as anything
// but the goal was for it not to collide with any other address
// that might be a real account address, OR anything that might be
// used elsewhere as a burn address OR anything that might to become 
// a special address in future versions of the EVM

pragma solidity 0.4.8;
import "../libraries/Owned.sol";
contract Proxy is Owned {
  event Forwarded (address indexed destination, uint value, bytes data);
  event Received (address indexed sender, uint value);
  event Created (address creation);
  
  function () payable { Received(msg.sender, msg.value); }

  function forward(address destination, uint value, bytes data) onlyOwner payable{
    if (destination == 0xC5c4BBF9bf69b54F1bB823385d127Bd7238eE7F6) {//sha3("createContractFromProxy")
        address creation;
        assembly {
            creation := create(value,add(data,0x20), mload(data))
            jumpi(invalidJumpLabel,iszero(extcodesize(creation)))
        }
        Created(creation);
    }else{
        if (!destination.call.value(value)(data)) { throw; }
        Forwarded(destination, value, data);
    }
  }
}
