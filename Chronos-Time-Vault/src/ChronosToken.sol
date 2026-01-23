// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ChronosToken {
    // 1. Owner Address
    address private _owner;

    // Token Metadata
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    // Token Numbers Info
    uint256 private _totalSupply;
    
    // Token Balance Mappings and Allowance Mapping
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
      
    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 initialSupply) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _owner = msg.sender;

        _mint(msg.sender, initialSupply * (10 ** uint256(decimals_)));
    }

    modifier onlyOwner(){
        require(msg.sender == _owner, "You are not Authorized");
        _;
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "Mint to zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function mintTo(address account,uint256 amount) public onlyOwner  returns (bool){
        _mint(account,amount);
        return true;
    }


    function owner() public view returns (address){
        return _owner;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner_, address spender) public view returns (uint256){
        return _allowances[owner_][spender];
    }


    function transfer(address to, uint256 value) public returns (bool success){
        require(_balances[msg.sender] >= value, "Insufficient Balance");
        require(to != address(0), "Transfer to zero address");

        _balances[msg.sender] -= value;
        _balances[to] += value; 
        emit Transfer(msg.sender, to, value);

        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success){
        require(_allowances[from][msg.sender] >= value, "Allowance exceeded");
        require(_balances[from] >= value, "Insufficient Balance");

        _balances[from] -= value;
        _balances[to] += value;
        
        _allowances[from][msg.sender] -= value;
        
        emit Transfer(from, to, value);

        return true;
    }

    function approve(address spender, uint256 value) public returns (bool success){
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);

        return true;
    }
}