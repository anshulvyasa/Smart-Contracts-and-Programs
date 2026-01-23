// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct User{
    uint256 _amount;
    uint256 _timeStamp;
}

contract Vault{
    mapping(address=>User) private addressToEth;

    constructor(){
       
    }

    function stake(uint256 lockperiod) public return (bool){
        return true;
    } 

    function withdraw(uint256 ) public return  {
        
    }
}