pragma solidity 0.4.8;

contract Owned {
  address public owner;
  modifier onlyOwner(){ if (msg.sender == owner) _; }

  function Owned(){ owner = msg.sender; }

  function transfer(address _owner) onlyOwner { owner = _owner; }
}
