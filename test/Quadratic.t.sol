// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "./handler/Handler_2.sol";
import "../src/Quadratic.sol";

contract InvariantQuadratic is Test {
    Quadratic quadratic;
    Handler_2 handler;

    function setUp() external {
        quadratic = new Quadratic();
        handler = new Handler_2(quadratic);

        targetContract(address(handler));
    }

    function invariant_NotOkay() external {
        assertTrue(quadratic.ok());
    }
}
