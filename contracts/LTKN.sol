// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LoyaltyTkn is ERC20 {
    constructor() ERC20("HabilidashLoyaltyToken", "HLT") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}