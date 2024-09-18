// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import "@openzeppelin-contracts-5.0.2/token/ERC20/ERC20.sol";

contract Token is ERC20{

    constructor(string memory _name,string memory _symbol,uint _initialMint)ERC20(_name,_symbol){
        _mint(_msgSender(),_initialMint);
    }
}
