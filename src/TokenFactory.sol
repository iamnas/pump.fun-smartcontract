// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import "./Token.sol";

contract TokenFactory {
    uint public constant DECIMAL = 10 ** 18;
    uint public constant MAX_SUPPLY = (10 ** 9) * DECIMAL;
    uint public constant INITIAL_SUPPLY = (MAX_SUPPLY * 20) / 100;

    mapping(address => bool) public tokens;
 
    function createToken(
        string memory _name,
        string memory _symbol
    ) external returns (address) {
        Token _tokenaddress = new Token(_name, _symbol, INITIAL_SUPPLY);
        tokens[address(_tokenaddress)] = true;
        return address(_tokenaddress);
    }

    
}
