// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./ERC20.sol";

contract MyToken is ERC20 {
    constructor() ERC20("MyToken", "MTK", 1000) {}
}
