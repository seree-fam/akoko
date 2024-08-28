// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./p256/verifier.sol";

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract Akoko {
    address public owner;
    IERC20 public usdcToken;
    IERC20 public usdtToken;

    enum Status { Paid, Unpaid }

    struct Order {
        bytes32 uuid;
        Status status; 
    }

    mapping(uint256 => Order) public orders;
    mapping(uint256 => uint256) public escrowBalances;

    event OrderPlaced(bytes32 indexed uuid);
    event Payout(bytes32 indexed uuid);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is NOT the owner");
        _;
    }

    receive() external payable {}

    fallback() external payable {}
}