// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CCNCarnival2025 {
    enum Duration { Friday, FridaySaturday, FridaySaturdaySunday }
    enum Day { Friday, Saturday, Sunday }
    enum Status { Open, ClosedByOwner, ClosedByTime, Withdrawn }

    struct Stall {
        address owner;
        string name;
        Duration duration;
        uint256 totalFunds;
        uint256 withdrawTime;
        Status status;
        bool isWithdrawn;
        mapping(address => uint256) payments;
        address[] payers;
        mapping(address => uint8) ratings;
        uint256 ratingsSum;
        uint256 ratingsCount;
    }

    uint256 public stallCount;
    mapping(uint256 => Stall) private stalls;
    mapping(uint256 => bool) public stallExists;

    event StallRegistered(uint256 indexed stallId, address indexed owner, string name, Duration duration);
    event PaymentMade(uint256 indexed stallId, address indexed payer, uint256 amount);
    event RefundIssued(uint256 indexed stallId, address indexed to, uint256 amount);
    event FundsWithdrawn(uint256 indexed stallId, address indexed owner, uint256 amount);
    event StallClosed(uint256 indexed stallId, address indexed owner, uint256 time, string reason);
    event StallRated(uint256 indexed stallId, address indexed rater, uint8 rating);

    modifier onlyStallOwner(uint256 stallId) {
        require(stallExists[stallId], "Stall does not exist");
        require(stalls[stallId].owner == msg.sender, "Caller is not stall owner");
        _;
    }

    modifier stallIsOpen(uint256 stallId) {
        Stall storage s = stalls[stallId];
        if (s.status == Status.Open && block.timestamp >= s.withdrawTime) {
            s.status = Status.ClosedByTime;
            emit StallClosed(stallId, s.owner, block.timestamp, "Closed due to duration end");
        }
        require(s.status == Status.Open, "Stall is not open");
        _;
    }

    uint256 public constant CARNIVAL_START = 1752019200; // 2025-08-08 00:00:00 UTC (Friday)
    uint256 public constant ONE_DAY = 1 days;

    function registerStall(string calldata name, Duration duration) external returns (uint256) {
        require(bytes(name).length > 0, "Stall name cannot be empty");
        stallCount++;
        uint256 stallId = stallCount;
        Stall storage s = stalls[stallId];
        s.owner = msg.sender;
        s.name = name;
        s.duration = duration;
        s.totalFunds = 0;
        s.isWithdrawn = false;
        s.status = Status.Open;
        s.ratingsSum = 0;
        s.ratingsCount = 0;

        if (duration == Duration.Friday) {
            s.withdrawTime = CARNIVAL_START + ONE_DAY;
        } else if (duration == Duration.FridaySaturday) {
            s.withdrawTime = CARNIVAL_START + 2 * ONE_DAY;
        } else {
            s.withdrawTime = CARNIVAL_START + 3 * ONE_DAY;
        }

        stallExists[stallId] = true;
        emit StallRegistered(stallId, msg.sender, name, duration);
        return stallId;
    }

    function payStall(uint256 stallId) external payable stallIsOpen(stallId) {
        require(stallExists[stallId], "Stall does not exist");
        require(msg.value > 0, "Payment must be greater than 0");
        Stall storage s = stalls[stallId];
        require(msg.sender != s.owner, "Owner cannot pay own stall");

        if (s.payments[msg.sender] == 0) {
            s.payers.push(msg.sender);
        }
        s.payments[msg.sender] += msg.value;
        s.totalFunds += msg.value;
        emit PaymentMade(stallId, msg.sender, msg.value);
    }

    function refund(uint256 stallId, address to, uint256 amount) external onlyStallOwner(stallId) stallIsOpen(stallId) {
        Stall storage s = stalls[stallId];
        require(s.payments[to] >= amount && amount > 0, "Invalid refund amount");
        require(s.totalFunds >= amount, "Not enough funds in stall");

        s.payments[to] -= amount;
        s.totalFunds -= amount;
        (bool sent, ) = payable(to).call{value: amount}("");
        require(sent, "Refund transfer failed");
        emit RefundIssued(stallId, to, amount);
    }

    function withdraw(uint256 stallId) external onlyStallOwner(stallId) {
        Stall storage s = stalls[stallId];
        require(
            s.status == Status.ClosedByOwner || s.status == Status.ClosedByTime,
            "Stall must be closed"
        );
        require(!s.isWithdrawn, "Funds already withdrawn");
        uint256 amount = s.totalFunds;
        require(amount > 0, "No funds to withdraw");

        s.isWithdrawn = true;
        s.totalFunds = 0;
        s.status = Status.Withdrawn;

        (bool sent, ) = payable(s.owner).call{value: amount}("");
        require(sent, "Withdraw transfer failed");

        emit FundsWithdrawn(stallId, s.owner, amount);
    }

    function closeStall(uint256 stallId) external onlyStallOwner(stallId) {
        Stall storage s = stalls[stallId];
        require(s.status == Status.Open, "Stall not open");
        s.status = Status.ClosedByOwner;
        emit StallClosed(stallId, s.owner, block.timestamp, "Closed by owner");
    }

    function rateStall(uint256 stallId, uint8 rating) external {
        require(stallExists[stallId], "Stall does not exist");
        require(rating >= 1 && rating <= 5, "Rating must be 1-5");
        Stall storage s = stalls[stallId];
        require(msg.sender != s.owner, "Owner cannot rate own stall");
        require(s.payments[msg.sender] > 0, "Only payers can rate");

        uint8 previous = s.ratings[msg.sender];
        if (previous == 0) {
            s.ratingsCount++;
            s.ratingsSum += rating;
        } else {
            s.ratingsSum = s.ratingsSum - previous + rating;
        }
        s.ratings[msg.sender] = rating;
        emit StallRated(stallId, msg.sender, rating);
    }

    function getRating(uint256 stallId, address user) external view returns (uint8) {
        return stalls[stallId].ratings[user];
    }

    function getAverageRating(uint256 stallId) external view returns (uint256 avgRating, uint256 ratingsCount) {
        Stall storage s = stalls[stallId];
        if (s.ratingsCount == 0) {
            return (0, 0);
        }
        return (s.ratingsSum / s.ratingsCount, s.ratingsCount);
    }

    function getStall(uint256 stallId) external view returns (
        address owner, string memory name, Duration duration, uint256 totalFunds, uint256 withdrawTime, Status status, bool isWithdrawn
    ) {
        Stall storage s = stalls[stallId];
        return (s.owner, s.name, s.duration, s.totalFunds, s.withdrawTime, s.status, s.isWithdrawn);
    }

    function getPayers(uint256 stallId) external view returns (address[] memory) {
        return stalls[stallId].payers;
    }

    function getPayment(uint256 stallId, address user) external view returns (uint256) {
        return stalls[stallId].payments[user];
    }
}