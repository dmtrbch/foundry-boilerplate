// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Counter.sol";

contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }

    // Add helpful error message as a third argument in asserts

    function testIncrement() public {
        counter.increment();
        assertEq(counter.number(), 1, "expect x to equal to 1");
    }

    function testSetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x, "x should be setNumber");
    }
}
