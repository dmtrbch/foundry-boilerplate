// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract InvariantDeposit {
    address public seller = msg.sender;
    mapping(address => uint256) public balance;

    function deposit() external payable {
        balance[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amount = balance[msg.sender];
        balance[msg.sender] = 0;
        (bool s, ) = msg.sender.call{value: amount}("");
        require(s, "failed to send");
    }
}
