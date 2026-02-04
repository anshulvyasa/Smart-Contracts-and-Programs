interface IChronosToken {
    function mintTo(address account, uint256 amount) external returns (bool);
    function owner() external view returns (address);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(
        address owner_,
        address spender
    ) external view returns (uint256);
    function transfer(
        address to,
        uint256 value
    ) external returns (bool success);
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool success);
    function approve(address spender, uint256 value) external returns (bool success);
}
