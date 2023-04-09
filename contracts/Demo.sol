// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract Demo {
    string public message;
    address public owner;
    mapping(address => uint) public balances;

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address _to) external {
        require(msg.sender == owner, "Not an owner");
        owner = _to;
    }

    function pay(string calldata _message) external payable {
        message = _message;
        balances[msg.sender] = msg.value;
    }
}
