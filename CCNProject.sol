// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CCNCarnival {
    enum StallDuration { Friday, FridaySaturday, FridaySaturdaySunday }
    enum StallStatus { Registered, Closed, Withdrawn }

    struct Stall {
        address owner;
        StallDuration duration;
        StallStatus status;
        uint256 balance;
        mapping(address => uint256) payments;
    }

    uint256 public stallCount;
    mapping(uint256 => Stall) private stalls;
    mapping(address => uint256[]) public ownerStalls;

    event StallRegistered(uint256 indexed stallId, address indexed owner, StallDuration duration);
    event PaymentReceived(uint256 indexed stallId, address indexed payer, uint256 amount);
    event RefundIssued(uint256 indexed stallId, address indexed to, uint256 amount);
    event Withdrawal(uint256 indexed stallId, address indexed owner, uint256 amount);

    modifier onlyStallOwner(uint256 stallId) {
        require(stalls[stallId].owner == msg.sender, "Not stall owner");
        _;
    }

    // Register a new stall with its operating duration
    function registerStall(StallDuration duration) external returns (uint256) {
        stallCount++;
        uint256 stallId = stallCount;

        Stall storage s = stalls[stallId];
        s.owner = msg.sender;
        s.duration = duration;
        s.status = StallStatus.Registered;

        ownerStalls[msg.sender].push(stallId);

        emit StallRegistered(stallId, msg.sender, duration);
        return stallId;
    }

    // Public users make payments to a stall
    function payToStall(uint256 stallId) external payable {
        require(stalls[stallId].owner != address(0), "Invalid stall");
        require(stalls[stallId].status == StallStatus.Registered, "Stall not accepting payments");
        require(msg.value > 0, "No payment sent");

        stalls[stallId].balance += msg.value;
        stalls[stallId].payments[msg.sender] += msg.value;

        emit PaymentReceived(stallId, msg.sender, msg.value);
    }

    // Stall owner refunds a user (full or partial)
    function refund(uint256 stallId, address payable to, uint256 amount) external onlyStallOwner(stallId) {
        require(stalls[stallId].payments[to] >= amount, "Refund exceeds payment");
        require(stalls[stallId].balance >= amount, "Insufficient balance in stall");

        stalls[stallId].payments[to] -= amount;
        stalls[stallId].balance -= amount;

        (bool sent, ) = to.call{value: amount}("");
        require(sent, "Refund failed");

        emit RefundIssued(stallId, to, amount);
    }

    // Mark stall as closed (should be called when the stall's operating period is over)
    function closeStall(uint256 stallId) external onlyStallOwner(stallId) {
        require(stalls[stallId].status == StallStatus.Registered, "Stall already closed or withdrawn");
        stalls[stallId].status = StallStatus.Closed;
    }

    // Stall owner withdraws funds after closing their stall
    function withdraw(uint256 stallId) external onlyStallOwner(stallId) {
        require(stalls[stallId].status == StallStatus.Closed, "Stall not closed yet");
        require(stalls[stallId].balance > 0, "Nothing to withdraw");

        uint256 amount = stalls[stallId].balance;
        stalls[stallId].balance = 0;
        stalls[stallId].status = StallStatus.Withdrawn;

        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "Withdrawal failed");

        emit Withdrawal(stallId, msg.sender, amount);
    }

    // View functions
    function getStall(uint256 stallId) external view returns (
        address owner,
        StallDuration duration,
        StallStatus status,
        uint256 balance
    ) {
        Stall storage s = stalls[stallId];
        return (s.owner, s.duration, s.status, s.balance);
    }

    function getUserPayment(uint256 stallId, address user) external view returns (uint256) {
        return stalls[stallId].payments[user];
    }

    function getOwnerStalls(address owner) external view returns (uint256[] memory) {
        return ownerStalls[owner];
    }
}