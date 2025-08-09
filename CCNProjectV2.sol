// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CCNCarnival2025 {
    enum Duration { Friday, FridaySaturday, FridaySaturdaySunday }
    enum Day { Friday, Saturday, Sunday }

    struct Stall {
        address owner;
        string name;
        Duration duration;
        uint256 totalFunds;
        uint256 withdrawTime;
        bool withdrawn;
        mapping(address => uint256) payments; // user => amount paid
        address[] payers;
    }

    uint256 public stallCount;
    mapping(uint256 => Stall) public stalls;
    mapping(uint256 => bool) public stallExists;

    event StallRegistered(uint256 indexed stallId, address indexed owner, string name, Duration duration);
    event PaymentMade(uint256 indexed stallId, address indexed payer, uint256 amount);
    event RefundIssued(uint256 indexed stallId, address indexed to, uint256 amount);
    event FundsWithdrawn(uint256 indexed stallId, address indexed owner, uint256 amount);

    modifier onlyStallOwner(uint256 stallId) {
        require(stallExists[stallId], "Stall does not exist");
        require(stalls[stallId].owner == msg.sender, "Not stall owner");
        _;
    }

    // Simulate start times for demonstration. In practice, use actual timestamps.
    uint256 public constant carnivalStart = 1752019200; // 2025-08-08 00:00:00 UTC (Friday)
    uint256 public constant oneDay = 1 days;

    function registerStall(string calldata name, Duration duration) external returns (uint256) {
        stallCount++;
        uint256 stallId = stallCount;
        Stall storage s = stalls[stallId];
        s.owner = msg.sender;
        s.name = name;
        s.duration = duration;
        s.totalFunds = 0;
        s.withdrawn = false;

        // Set withdrawal time based on duration
        if (duration == Duration.Friday) {
            s.withdrawTime = carnivalStart + oneDay; // End of Friday
        } else if (duration == Duration.FridaySaturday) {
            s.withdrawTime = carnivalStart + 2 * oneDay; // End of Saturday
        } else {
            s.withdrawTime = carnivalStart + 3 * oneDay; // End of Sunday
        }

        stallExists[stallId] = true;
        emit StallRegistered(stallId, msg.sender, name, duration);
        return stallId;
    }

    function payStall(uint256 stallId) external payable {
        require(stallExists[stallId], "Stall does not exist");
        require(msg.value > 0, "Payment must be > 0");
        Stall storage s = stalls[stallId];
        if (s.payments[msg.sender] == 0) {
            s.payers.push(msg.sender);
        }
        s.payments[msg.sender] += msg.value;
        s.totalFunds += msg.value;
        emit PaymentMade(stallId, msg.sender, msg.value);
    }

    function refund(uint256 stallId, address to, uint256 amount) external onlyStallOwner(stallId) {
        Stall storage s = stalls[stallId];
        require(s.payments[to] >= amount, "Not enough paid by user");
        require(s.totalFunds >= amount, "Not enough funds in stall");
        s.payments[to] -= amount;
        s.totalFunds -= amount;
        payable(to).transfer(amount);
        emit RefundIssued(stallId, to, amount);
    }

    function withdraw(uint256 stallId) external onlyStallOwner(stallId) {
        Stall storage s = stalls[stallId];
        require(block.timestamp >= s.withdrawTime, "Too early to withdraw");
        require(!s.withdrawn, "Already withdrawn");
        uint256 amount = s.totalFunds;
        require(amount > 0, "No funds to withdraw");
        s.withdrawn = true;
        s.totalFunds = 0;
        payable(s.owner).transfer(amount);
        emit FundsWithdrawn(stallId, s.owner, amount);
    }

    // Read-only functions for UI/queries

    function getStall(uint256 stallId) external view returns (
        address owner, string memory name, Duration duration, uint256 totalFunds, uint256 withdrawTime, bool withdrawn
    ) {
        Stall storage s = stalls[stallId];
        return (s.owner, s.name, s.duration, s.totalFunds, s.withdrawTime, s.withdrawn);
    }

    function getPayers(uint256 stallId) external view returns (address[] memory) {
        return stalls[stallId].payers;
    }

    function getPayment(uint256 stallId, address user) external view returns (uint256) {
        return stalls[stallId].payments[user];
    }
}