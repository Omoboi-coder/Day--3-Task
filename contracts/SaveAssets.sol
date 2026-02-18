// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./OmoboiToken.sol";

contract SaveAssets {

    OmoboiToken public token;

    mapping(address => uint256) public etherBalances;
    mapping(address => uint256) public tokenBalances;

    constructor(address _tokenAddress) {
        token = OmoboiToken(_tokenAddress);
    }

    function depositEther() external payable {
        require(msg.value > 0, "Send Ether");
        etherBalances[msg.sender] += msg.value;
    }

    function withdrawEther(uint256 _amount) external {
        require(etherBalances[msg.sender] >= _amount, "Insufficient Ether");

        etherBalances[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
    }

    function depositToken(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero");

        bool success = token.transferFrom(msg.sender, address(this), _amount);
        require(success, "Transfer failed");

        tokenBalances[msg.sender] += _amount;
    }

    function withdrawToken(uint256 _amount) external {
        require(tokenBalances[msg.sender] >= _amount, "Insufficient Token");

        tokenBalances[msg.sender] -= _amount;

        bool success = token.transfer(msg.sender, _amount);
        require(success, "Withdraw failed");
    }

    function getEtherBalance() external view returns (uint256) {
        return etherBalances[msg.sender];
    }

    function getTokenBalance() external view returns (uint256) {
        return tokenBalances[msg.sender];
    }

    receive() external payable {}
}
