// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Akoko {
    address public owner;

    enum Status { Paid, Unpaid }

    struct Order {
        bytes32 uuid;
        Status status;
        uint256 amount;
        uint256 recipient; // the recipient is typically a phone number
    }

    mapping(uint256 => Order) public orders;
    mapping(uint256 => uint256) public escrowBalances;

    event OrderPlaced(bytes32 indexed uuid, uint256 indexed amount, uint256 indexed recipient);
    event Payout(bytes32 indexed uuid, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function placeOrder(bytes32 _uuid, uint256 _recipient) public payable {
        require(msg.value > 0, "ETH amount must be greater than 0");

        Order memory newOrder = Order({
            uuid: _uuid,
            status: Status.Unpaid,
            amount: uint256(msg.value),
            recipient: _recipient
        });

        orders[uint256(_uuid)] = newOrder;
        escrowBalances[uint256(_uuid)] = msg.value;

        emit OrderPlaced(_uuid, msg.value, _recipient);
    }

    function payout(bytes32 _uuid) public onlyOwner {
        Order storage order = orders[uint256(_uuid)];
        require(order.status == Status.Unpaid, "Order is already paid or does not exist");

        uint256 amount = escrowBalances[uint256(_uuid)];
        require(amount > 0, "No funds to payout");

        order.status = Status.Paid;
        escrowBalances[uint256(_uuid)] = 0;

        (bool success, ) = owner.call{value: amount}("");
        require(success, "ETH transfer failed");

        emit Payout(_uuid, amount);
    }

    receive() external payable {}

    fallback() external payable {}
}