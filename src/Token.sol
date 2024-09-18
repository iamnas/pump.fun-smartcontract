// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import "@openzeppelin-contracts-5.0.2/token/ERC20/ERC20.sol";
import "@openzeppelin-contracts-5.0.2/access/Ownable.sol";

contract Token is ERC20,Ownable{

    constructor(string memory _name,string memory _symbol,uint _initialMint)ERC20(_name,_symbol) Ownable(_msgSender()){
        _mint(_msgSender(),_initialMint);
    }

    function mint(address _to,uint _amount) external onlyOwner{
        _mint(_to,_amount);
    }
}
