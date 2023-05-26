// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/CustomErrorContract.sol";

contract CustomErrorTest is Test {
    CustomErrorContract public customErrorContract;
    error SomeError(uint256);

    function setUp() public {
        customErrorContract = new CustomErrorContract();
    }

    /* =============================================
     * Testing Custom Errors
     * =============================================
     */
    function testRevert() public {
        // 5 is an arbitrary example
        vm.expectRevert(abi.encodeWithSelector(SomeError.selector, 5));
        customErrorContract.revertError(5);
    }
}
