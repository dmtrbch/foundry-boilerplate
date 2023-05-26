// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Deposit.sol";

contract DepositTest is Test {
    Deposit public depositContract;

    function setUp() public {
        depositContract = new Deposit();
    }

    /* =============================================
     * Checking balances
     * =============================================
     */
    function testBuyerDeposit() public {
        uint256 balanceBefore = address(depositContract).balance;
        depositContract.buyerDeposit{value: 1 ether}();
        uint256 balanceAfter = address(depositContract).balance;

        assertEq(
            balanceAfter - balanceBefore,
            1 ether,
            "expect increase of 1 ether"
        );
    }

    /* =============================================
     * Expecting reverts with vm.expectRevert
     * =============================================
     */
    function testBuyerDepositWrongPrice() public {
        vm.expectRevert("incorrect amount");
        depositContract.buyerDeposit{value: 1 ether + 1 wei}();

        vm.expectRevert("incorrect amount");
        depositContract.buyerDeposit{value: 1 ether - 1 wei}();
    }
}
