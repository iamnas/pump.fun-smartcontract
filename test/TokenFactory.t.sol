// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TokenFactory} from "../src/TokenFactory.sol";
import {Token} from "../src/Token.sol";

contract TokenFactoryTest is Test {
    TokenFactory public tokenFactory;

    function setUp() public {
        tokenFactory = new TokenFactory();

        // counter.setNumber(0);
    }

    function test_CreateToken() public {
        string memory name= "Test TOKEN";
        string memory symbol = "TT";
        address tokenAddress = tokenFactory.createToken(name,symbol);
        Token token = Token(tokenAddress);
        
        assertEq(tokenFactory.tokens(tokenAddress),true);
        assertEq(token.totalSupply(),tokenFactory.INITIAL_SUPPLY());

    }

    // function testFuzz_SetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
