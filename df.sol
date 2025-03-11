// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract FraudDetection is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant AUDITOR_ROLE = keccak256("AUDITOR_ROLE");
    bytes32 public constant USER_ROLE = keccak256("USER_ROLE");
    
    enum TransactionStatus { Safe, Suspicious, Fraudulent }
    
    struct Transaction {
        uint256 id;
        address sender;
        address receiver;
        uint256 amount;
        TransactionStatus status;
        string reason;
        uint256 timestamp;
    }
    
    mapping(uint256 => Transaction) public transactions;
    mapping(address => uint256) public reputationScores;
    mapping(address => bool) public blacklisted;
    uint256 public transactionCount;
    
    event TransactionRecorded(uint256 id, address sender, address receiver, uint256 amount, TransactionStatus status, string reason);
    event ReputationUpdated(address indexed user, uint256 score);
    event UserBlacklisted(address indexed user);
    
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }
    
    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Only admin can perform this action");
        _;
    }
    
    function recordTransaction(address _sender, address _receiver, uint256 _amount, TransactionStatus _status, string memory _reason) public onlyAdmin {
        require(!blacklisted[_sender], "Sender is blacklisted");
        transactionCount++;
        transactions[transactionCount] = Transaction(transactionCount, _sender, _receiver, _amount, _status, _reason, block.timestamp);
        emit TransactionRecorded(transactionCount, _sender, _receiver, _amount, _status, _reason);
        
        if (_status == TransactionStatus.Fraudulent) {
            updateReputation(_sender, false);
        } else {
            updateReputation(_sender, true);
        }
    }
    
    function updateReputation(address user, bool isLegit) internal {
        if (isLegit) {
            reputationScores[user] += 10;
        } else {
            if (reputationScores[user] > 10) {
                reputationScores[user] -= 10;
            } else {
                reputationScores[user] = 0;
            }
        }
        emit ReputationUpdated(user, reputationScores[user]);
        
        if (reputationScores[user] == 0) {
            blacklisted[user] = true;
            emit UserBlacklisted(user);
        }
    }
    
    function getTransaction(uint256 _id) public view returns (Transaction memory) {
        return transactions[_id];
    }
    
    function checkReputation(address user) public view returns (uint256) {
        return reputationScores[user];
    }
    
    function isBlacklisted(address user) public view returns (bool) {
        return blacklisted[user];
    }
}
