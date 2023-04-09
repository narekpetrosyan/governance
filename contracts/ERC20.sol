// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./IERC20.sol";

contract ERC20 is IERC20 {
    uint totalTokens;
    address owner;
    string _name;
    string _symbol;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowances;

    constructor(
        string memory name_,
        string memory symbol_,
        uint initialSupply_
    ) {
        _name = name_;
        _symbol = symbol_;
        owner = msg.sender;
        mint(initialSupply_, owner);
    }

    modifier enoughTokens(address _from, uint _amount) {
        require(balanceOf(_from) >= _amount, "Insufficient funds.");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner.");
        _;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function decimals() external pure override returns (uint) {
        return 18; // 1 token = 1 wei
    }

    function burn(
        address _from,
        uint amount
    ) external onlyOwner enoughTokens(_from, amount) {
        _beforeTokenTransferred(_from, address(0), amount);
        balances[_from] -= amount;
        totalTokens -= amount;
    }

    function mint(uint amount, address shop) public onlyOwner {
        _beforeTokenTransferred(address(0), shop, amount);
        balances[shop] += amount;
        totalTokens += amount;
        emit Transfer(address(0), shop, amount);
    }

    function totalSupply() external view override returns (uint) {
        return totalTokens;
    }

    function balanceOf(address account) public view override returns (uint) {
        return balances[account];
    }

    function transfer(
        address to,
        uint256 amount
    ) external enoughTokens(msg.sender, amount) {
        _beforeTokenTransferred(msg.sender, to, amount);
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function allowance(
        address _owner,
        address spender
    ) public view returns (uint) {
        return allowances[_owner][spender];
    }

    function approve(address spender, uint amount) public {
        _approve(msg.sender, spender, amount);
    }

    function _approve(
        address sender,
        address spender,
        uint amount
    ) internal virtual {
        allowances[sender][spender] = amount;
        emit Approve(sender, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external enoughTokens(sender, amount) {
        _beforeTokenTransferred(sender, recipient, amount);
        // require(allowances[sender][recipient] >= amount, "check allowance");
        allowances[sender][recipient] -= amount;
        balances[sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _beforeTokenTransferred(
        address from,
        address to,
        uint amount
    ) internal virtual {}
}
