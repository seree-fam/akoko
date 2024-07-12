// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract Akoko {
    address public owner;
    IERC20 public usdcToken;

    enum Status { Paid, Unpaid }

    struct Order {
        string uuid;
        uint256 id; // hash of the uuid
        Status status;
        uint256 amount;
        string recipient; // the recipient is typically a phone number
    }

    mapping(uint256 => Order) public orders;
    mapping(uint256 => uint256) public escrowBalances;

    event OrderPlaced(string indexed uuid, uint256 indexed id, Status status, uint256 amount, string recipient);
    event Payout(uint256 indexed id, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor(address _usdcTokenAddress) {
        owner = msg.sender;
        usdcToken = IERC20(_usdcTokenAddress);
    }

    function placeOrder(string memory _uuid, uint256 _id, string memory _recipient, uint256 _usdcAmount) public {
        require(_usdcAmount > 0, "USDC amount must be greater than 0");

        uint256 allowance = usdcToken.allowance(msg.sender, address(this));
        require(allowance >= _usdcAmount, "Check the token allowance");

        Order memory newOrder = Order({
            uuid: _uuid,
            id: _id,
            status: Status.Unpaid,
            amount: _usdcAmount,
            recipient: _recipient
        });

        orders[_id] = newOrder;
        escrowBalances[_id] = _usdcAmount;

        bool success = usdcToken.transferFrom(msg.sender, address(this), _usdcAmount);
        require(success, "USDC transfer failed");

        emit OrderPlaced(_uuid, _id, Status.Unpaid, _usdcAmount, _recipient);
    }

    function payout(uint256 _id) public onlyOwner {
        Order storage order = orders[_id];
        require(order.status == Status.Unpaid, "Order is already paid or does not exist");

        uint256 amount = escrowBalances[_id];
        require(amount > 0, "No funds to payout");

        order.status = Status.Paid;
        escrowBalances[_id] = 0;

        bool success = usdcToken.transfer(owner, amount);
        require(success, "USDC transfer failed");

        emit Payout(_id, amount);
    }
}