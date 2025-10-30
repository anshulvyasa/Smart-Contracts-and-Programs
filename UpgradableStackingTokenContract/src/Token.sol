pragma solidity ^0.8.0;

contract Nimbus {
    address _owner;
    error UnauthorizedAccount(address account);
    error InvalidAccount(address account);
    event OwnerChanged(address indexed prevOwner, address indexed newOwner);

    mapping(address account => uint256) private _balances;
    mapping(address account => uint256) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor() {
        _owner = msg.sender;
    }

    //*********************************************************************************************************************************************/
    // OwnerShip Related Functions and modifier
    modifier onlyowner() {
        _checkowner();
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function _checkowner() internal view {
        if (owner() != msg.sender) {
            revert UnauthorizedAccount(msg.sender);
        }
    }

    function transferOwnerShip(address newOwner) public onlyowner {
        if (newOwner == address(0)) {
            revert InvalidAccount(address(0));
        }
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        address prevowner = _owner;
        _owner = newOwner;
        emit OwnerChanged(prevowner, newOwner);
    }

    function renounceOwnership() public onlyowner {
        _transferOwnership(address(0));
    }

    //******************************************************************************************************************************************* */
    // coin related function

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimal() public pure returns (uint8) {
        return 2;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _account) public view returns (uint256) {
        return _balances[_account];
    }

    
}
