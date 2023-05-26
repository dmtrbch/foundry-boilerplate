// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Deposit {
    event Deposited(address indexed);

    function buyerDeposit() external payable {
        require(msg.value == 1 ether, "incorrect amount");
        emit Deposited(msg.sender);
    }

    // rest of the logic
}
