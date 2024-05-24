// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../Verifier.sol";
import "../interfaces/IORMP.sol";

contract Oracle is Verifier {
    event SetFee(uint256 indexed chainId, uint256 fee);
    event SetApproved(address operator, bool approve);
    event Withdrawal(address indexed to, uint256 amt);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    address public immutable PROTOCOL;

    address public owner;
    // chainId => price
    mapping(uint256 => uint256) public feeOf;
    // operator => isApproved
    mapping(address => bool) public approvedOf;

    modifier onlyOwner() {
        require(msg.sender == owner, "!owner");
        _;
    }

    modifier onlyApproved() {
        require(isApproved(msg.sender), "!approve");
        _;
    }

    constructor(address dao, address ormp) {
        PROTOCOL = ormp;
        owner = dao;
    }

    receive() external payable {}

    function version() public pure returns (string memory) {
        return "2.0.0";
    }

    /// @dev Only could be called by owner.
    /// @param chainId The source chain id.
    /// @param channel The message channel.
    /// @param msgIndex The source chain message index.
    /// @param msgHash The source chain message hash corresponding to the channel.
    function importMessageHash(uint256 chainId, address channel, uint256 msgIndex, bytes32 msgHash)
        external
        onlyOwner
    {
        IORMP(PROTOCOL).importHash(chainId, channel, msgIndex, msgHash);
    }

    function hashOf(uint256 chainId, address channel, uint256 msgIndex) public view override returns (bytes32) {
        return IORMP(PROTOCOL).hashLookup(address(this), keccak256(abi.encode(chainId, channel, msgIndex)));
    }

    function changeOwner(address newOwner) external onlyOwner {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function setApproved(address operator, bool approve) external onlyOwner {
        approvedOf[operator] = approve;
        emit SetApproved(operator, approve);
    }

    function isApproved(address operator) public view returns (bool) {
        return approvedOf[operator];
    }

    function withdraw(address to, uint256 amount) external onlyApproved {
        (bool success,) = to.call{value: amount}("");
        require(success, "!withdraw");
        emit Withdrawal(to, amount);
    }

    function setFee(uint256 chainId, uint256 fee_) external onlyApproved {
        feeOf[chainId] = fee_;
        emit SetFee(chainId, fee_);
    }

    function fee(uint256 toChainId, address /*ua*/ ) public view returns (uint256) {
        uint256 f = feeOf[toChainId];
        require(f != 0, "!fee");
        return f;
    }
}
