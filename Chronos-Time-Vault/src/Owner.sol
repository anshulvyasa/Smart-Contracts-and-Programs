// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Owner {
    address owner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "You are not Authorized to Perform this Action"
        );
        _;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function changeOwner(address _newOwner) public onlyOwner returns (bool) {
        owner = _newOwner;
        return true;
    }
}
