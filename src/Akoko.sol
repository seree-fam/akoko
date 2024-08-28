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
    address public usdcContract;
    address public usdtContract;
    IERC20 public usdcToken;
    IERC20 public usdtToken;

    enum Status { Paid, Unpaid }
    enum Token { Ether, Usdc, Usdt }

    struct Order {
        bytes32 uuid;
        Status status; 
        Token token;
    }

    mapping(uint256 => Order) public orders;
    mapping(uint256 => uint256) public escrowBalances;

    event OrderPlaced(bytes32 indexed uuid);
    event Payout(bytes32 indexed uuid);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is NOT the owner");
        _;
    }

    constructor () {
        owner = msg.sender;
    }

    function placeOrderEth(bytes32 _uuid) public payable {
        require(msg.value > 0, "ETH amount must be greater than 0");

        Order memory newOrder = Order({
            uuid: _uuid,
            status: Status.Unpaid,
            token: Token.Ether
        });

        orders[uint256(_uuid)] = newOrder;
        escrowBalances[uint256(_uuid)] = msg.value;

        emit OrderPlaced(_uuid);
    }

    function placeOrderUSDC(bytes32 _uuid, uint256 _usdcAmount) public {
        require(_usdcAmount > 0, "USDC amount must be greater than 0");

        uint256 allowance = usdcToken.allowance(msg.sender, address(this));
        require(allowance >= _usdcAmount, "Please check the token allowance");

        Order memory newOrder = Order({
            uuid: _uuid,
            status: Status.Unpaid,
            token: Token.Usdc
        });

        orders[uint256(_uuid)] = newOrder;
        escrowBalances[uint256(_uuid)] = _usdcAmount;

        bool success = usdcToken.transferFrom(msg.sender, address(this), _usdcAmount);
        require(success, "USDC transfer failed");

        emit OrderPlaced(_uuid);
    }

    function placeOrderUSDT(bytes32 _uuid, uint256 _usdtAmount) public {
        require(_usdtAmount > 0, "USDT amount must be greater than 0");

        uint256 allowance = usdtToken.allowance(msg.sender, address(this));
        require(allowance >= _usdtAmount, "Please check the token allowance");

        Order memory newOrder = Order({
            uuid: _uuid,
            status: Status.Unpaid,
            token: Token.Usdt
        });

        orders[uint256(_uuid)] = newOrder;
        escrowBalances[uint256(_uuid)] = _usdtAmount;

        bool success = usdtToken.transferFrom(msg.sender, address(this), _usdtAmount);
        require(success, "USDT transfer failed");

        emit OrderPlaced(_uuid);
    }

    function payout(bytes32 _uuid, bytes32 message_hash, uint256 r, uint256 s, uint256 x, uint256 y) public onlyOwner {
        // First, we should verify the signature
        SignatureVerifier sigVerifier = new SignatureVerifier();
        bool isValidSignature = sigVerifier.verify(message_hash, r, s, x, y);
        require(isValidSignature, "Invalid signature");

        // Second, we should pay out the funds depending on which token was used
        Order storage order = orders[uint256(_uuid)];
        require(order.status == Status.Unpaid, "Order already paid");

        uint256 amount = escrowBalances[uint256(_uuid)];
        require(amount > 0, "No funds to pay out");

        if (order.token == Token.Ether) {
            payable(msg.sender).transfer(amount);
        } else if (order.token == Token.Usdc) {
            require(usdcToken.transfer(msg.sender, amount), "USDC transfer failed");
        } else if (order.token == Token.Usdt) {
            require(usdtToken.transfer(msg.sender, amount), "USDT transfer failed");
        }

        order.status = Status.Paid;
        escrowBalances[uint256(_uuid)] = 0;

        emit Payout(_uuid);
    }

    receive() external payable {}

    fallback() external payable {}
}