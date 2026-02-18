// Task 3 DAY 3
// requirements
// Write a smart contract that can save both ERC20 and ether for a user.

// Users must be able to:
// check individual balances,
// deposit or save in the contract.
// withdraw their savings


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);
}

contract SaveAssets {

    mapping(address => uint256) public etherBalances;


    mapping(address => mapping(address => uint256)) public tokenBalances;


    event EtherDeposited(address indexed user, uint256 amount);
    
    event EtherWithdrawn(address indexed user, uint256 amount);

    event TokenDeposited(address indexed user, address indexed token, uint256 amount);

    event TokenWithdrawn(address indexed user, address indexed token, uint256 amount);




    function depositEther() external payable {
        require(msg.value > 0, "Must send Ether");

        etherBalances[msg.sender] += msg.value;

        emit EtherDeposited(msg.sender, msg.value);
    }

    function withdrawEther(uint256 _amount) external {

        uint256 balance = etherBalances[msg.sender];

        require(balance >= _amount, "Insufficient Ether balance");

        etherBalances[msg.sender] -= _amount;

        (bool success, ) = payable(msg.sender).call{value: _amount}("");

        require(success, "Ether transfer failed");

        emit EtherWithdrawn(msg.sender, _amount);
    }

    function getEtherBalance() external view returns (uint256) {
        return etherBalances[msg.sender];
    }



    function depositToken(address _token, uint256 _amount) external {

        require(_amount > 0, "Amount must be greater than zero");

        IERC20 token = IERC20(_token);

        bool success = token.transferFrom(msg.sender, address(this), _amount);

        require(success, "Token transfer failed");

        tokenBalances[msg.sender][_token] += _amount;

        emit TokenDeposited(msg.sender, _token, _amount);
    }

    function withdrawToken(address _token, uint256 _amount) external {

        uint256 savedAmount = tokenBalances[msg.sender][_token];
        
        require(savedAmount >= _amount, "Insufficient token balance");

        tokenBalances[msg.sender][_token] -= _amount;

        bool success = IERC20(_token).transfer(msg.sender, _amount);
        require(success, "Token withdrawal failed");

        emit TokenWithdrawn(msg.sender, _token, _amount);
    }

    function getTokenBalance(address _token) external view returns (uint256) {
        return tokenBalances[msg.sender][_token];
    }


    receive() external payable {}
    fallback() external payable {}
}
