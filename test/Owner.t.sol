// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Owner.sol";

contract OwnerTest is Test {
    Owner public ownerContract;

    function setUp() public {
        ownerContract = new Owner();
    }

    /* =============================================
     * Changing msg.sender with foundry vm.prank
     * =============================================
     */
    function testChangeOwner() public {
        address owner = ownerContract.owner();
        address newOwner = address(1234);

        vm.prank(owner);
        ownerContract.changeOwner(newOwner);
        assertEq(
            ownerContract.owner(),
            newOwner,
            "expect owner to be set to newOwner"
        );
    }

    /* =============================================
     * If we want a sequence of transactions to use the same address
     * =============================================
     */
    function testMultipleTransactions() public {
        address owner = address(1234);
        vm.startPrank(owner);
        // behave as owner
        vm.stopPrank();
    }

    /* =============================================
     * Defining accounts and addresses in Foundry
     * =============================================
     */
    function testDefineAccounts() public {
        // an address created by casting a decimal to an address
        address owner = address(1234);

        // vitalik's addresss
        address vitalik = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045;

        // create an address from a known private key;
        uint privateKey = 1234; // can be read from env
        address fromPrivKey = vm.addr(privateKey);

        // create an attacker
        address hacker = address(0x00baddad);

        /* =============================================
         * If we specifically want control over both tx.origin and msg.sender
         * both vm.prank and vm.startPrank optionally take two arguments
         * where the second argument is tx.origin
         * this is not very good practice
         * =============================================
         */
        // vm.prank(msgSender, txOrigin);
    }
}
