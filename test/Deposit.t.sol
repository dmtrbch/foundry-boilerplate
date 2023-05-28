// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Deposit.sol";
import "../src/RejectTransaction.sol";

contract DepositTest is Test {
    Deposit public deposit;
    Deposit public faildeposit;
    address constant SELLER = address(0x5E11E7);
    //address constant Rejector = address(RejectTransaction);
    RejectTransaction private rejector;

    event Deposited(address indexed);
    event SellerWithdraw(address indexed, uint256 indexed);

    function setUp() public {
        deposit = new Deposit(SELLER);
        rejector = new RejectTransaction();
        faildeposit = new Deposit(address(rejector));
    }

    address public buyer = address(this); // the DepositTest contract is the "buyer"
    address public buyer2 = address(0x5E11E1); // random address
    address public FakeSELLER = address(0x5E1222); // random address

    /* =============================================
     * Checking balances
     * =============================================
     */
    function testBuyerDeposit() public {
        uint256 balanceBefore = address(deposit).balance;
        deposit.buyerDeposit{value: 1 ether}();
        uint256 balanceAfter = address(deposit).balance;

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
        deposit.buyerDeposit{value: 1 ether + 1 wei}();

        vm.expectRevert("incorrect amount");
        deposit.buyerDeposit{value: 1 ether - 1 wei}();
    }

    /* =============================================
     * Testing logs and events with vm.expectEvent
     * =============================================
     */
    function testBuyerDepositEvent() public {
        vm.expectEmit();
        emit Deposited(buyer);

        deposit.buyerDeposit{value: 1 ether}();
    }

    /* =============================================
     * Adjusting block.timestamp with vm.warp
     * =============================================
     */
    modifier startAtPresentDay() {
        vm.warp(1685131464);
        _;
    }

    function testDepositAmount() public startAtPresentDay {
        // this test checks that the buyer can only deposit 1 ether
        vm.startPrank(buyer);
        vm.expectRevert();
        deposit.buyerDeposit{value: 1.5 ether}();
        vm.expectRevert();
        deposit.buyerDeposit{value: 2.5 ether}();
        vm.stopPrank();
    }

    /* =============================================
     * Adjusting block.number with vm.roll
     * =============================================
     */
    // ============================================== //

    function testBuyerDepositSellerWithdrawAfter3days()
        public
        startAtPresentDay
    {
        // This test checks that the seller is able to withdraw 3 days after the buyer deposits

        // buyer deposits 1 ether
        vm.startPrank(buyer); // msg.sender == buyer
        deposit.buyerDeposit{value: 1 ether}();
        assertEq(
            address(deposit).balance,
            1 ether,
            "Contract balance did not increase"
        ); // checks to see if the contract balance increases
        vm.stopPrank();

        // after three days the seller withdraws
        vm.startPrank(SELLER); // msg.sender == SELLER
        vm.warp(1685131464 + 3 days + 1 seconds);
        deposit.sellerWithdraw(address(this));
        assertEq(
            address(deposit).balance,
            0 ether,
            "Contract balance did not decrease"
        ); // checks to see if the contract balance decreases
    }

    function testBuyerDepositSellerWithdrawBefore3days()
        public
        startAtPresentDay
    {
        // This test checks that the seller is able to withdraw 3 days after the buyer deposits

        // buyer deposits 1 ether
        vm.startPrank(buyer); // msg.sender == buyer
        deposit.buyerDeposit{value: 1 ether}();
        assertEq(
            address(deposit).balance,
            1 ether,
            "Contract balance did not increase"
        ); // checks to see if the contract balance increases
        vm.stopPrank();

        // before three days the seller withdraws
        vm.startPrank(SELLER); // msg.sender == SELLER
        vm.warp(1685131464 + 2 days);
        vm.expectRevert(); // expects a revert
        deposit.sellerWithdraw(address(this));
    }

    function testUserDepositTwice() public startAtPresentDay {
        // This test checks that a user cannot deposit twice

        vm.startPrank(buyer); // msg.sender == buyer
        deposit.buyerDeposit{value: 1 ether}();

        vm.warp(1685131464 + 1 days); // one day later...
        vm.expectRevert();
        deposit.buyerDeposit{value: 1 ether}(); // should revert since it hasn't been 3 days
    }

    function testNonExistantContract() public startAtPresentDay {
        // This test checks that the seller cannot withdraw for non-existent addresses

        vm.startPrank(SELLER); // msg.sender == SELLER
        vm.expectRevert();
        deposit.sellerWithdraw(buyer);
    }

    function testBuyerBuysAgain() public startAtPresentDay {
        // This test checks that the entry for the buyer is deleted (this allows the buyer to buy again)

        vm.startPrank(buyer); // msg.sender == buyer
        deposit.buyerDeposit{value: 1 ether}();
        vm.stopPrank();

        // seller withdraws
        vm.warp(1685131464 + 3 days + 1 seconds);
        vm.startPrank(SELLER); // msg.sender == SELLER
        deposit.sellerWithdraw(buyer);
        vm.stopPrank();

        // checks depostitime[buyer] == 0
        assertEq(
            deposit.depositTime(buyer),
            0,
            "entry for buyer is not deleted"
        );

        // buyer deposits again
        vm.startPrank(buyer); // msg.sender == buyer
        vm.expectEmit();
        emit Deposited(buyer);
        deposit.buyerDeposit{value: 1 ether}();
        vm.stopPrank();
    }

    function testSellerWithdrawEmitted() public startAtPresentDay {
        // this test checks that the SellerWithdraw event is emitted

        //buyer2 deposits
        vm.deal(buyer2, 1 ether); // msg.sender == buyer2
        vm.startPrank(buyer2);
        vm.expectEmit(); // Deposited Emitter checked
        emit Deposited(buyer2);
        deposit.buyerDeposit{value: 1 ether}();
        vm.stopPrank();

        vm.warp(1685131464 + 3 days + 1 seconds); // 3 day and 1 second later...

        // seller withdraws + checks SellerWithdraw event emmited or not
        vm.startPrank(SELLER); // msg.sender == SELLER
        vm.expectEmit(); // expects SellerWithdraw Emitterd
        emit SellerWithdraw(buyer2, block.timestamp);
        deposit.sellerWithdraw(buyer2);
        vm.stopPrank();
    }

    function testFakeSeller2Withdraw() public startAtPresentDay {
        // buyer deposits
        vm.startPrank(buyer);
        vm.deal(buyer, 2 ether); // this contract's address is the buyer
        deposit.buyerDeposit{value: 1 ether}();
        vm.stopPrank();
        assertEq(
            address(deposit).balance,
            1 ether,
            "Ether deposited somehow failed"
        );

        vm.warp(1685131464 + 3 days + 1 seconds); // 3 day and 1 second later...

        vm.startPrank(FakeSELLER); // msg.sender == FakeSELLER
        vm.expectRevert();
        deposit.sellerWithdraw(buyer);
        vm.stopPrank();
    }

    function testRejectedWithdrawl() public startAtPresentDay {
        // This test checks that the entry for the buyer is deleted (this allows the buyer to buy again)

        vm.startPrank(buyer); // msg.sender == buyer
        faildeposit.buyerDeposit{value: 1 ether}();
        vm.stopPrank();
        assertEq(address(faildeposit).balance, 1 ether, "assertion failed");

        vm.warp(1680616584 + 3 days + 1 seconds); // 3 days and 1 second later...

        vm.startPrank(address(rejector)); // msg.sender == rejector
        vm.expectRevert();
        faildeposit.sellerWithdraw(buyer);
        vm.stopPrank();
    }

    /* =============================================
     * Setting address balances with vm.deal and vm.hoax
     * =============================================
     */
    //vm.hoax(addressToPrank, balanceToGive);
    // next call is a prank for addressToPrank
    // vm.deal(alice, balanceToGive);

    /* =============================================
     * FUZZING
     * =============================================
     */
    function testFuzzBuyerDepositWrongPrice(uint256 price) public {
        vm.assume(price != 1 ether);
        vm.deal(buyer, price);

        vm.expectRevert("incorrect amount");
        deposit.buyerDeposit{value: price}();
    }

    function testFuzzDepositAmount(uint256 price) public startAtPresentDay {
        // this test checks that the buyer can only deposit 1 ether
        vm.assume(price != 1 ether);
        vm.deal(buyer, price);

        vm.startPrank(buyer);
        vm.expectRevert();
        deposit.buyerDeposit{value: price}();
        vm.expectRevert();
        deposit.buyerDeposit{value: price}();
        vm.stopPrank();
    }
}
