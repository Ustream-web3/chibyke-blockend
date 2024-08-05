// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {StreamToken} from "../../src/StreamToken.sol";

contract TestStreamToken is Test {
    StreamToken streamToken;

    address guardian = makeAddr("guardian");
    address Chibyke = makeAddr("Chibyke");
    address David = makeAddr("David");

    function setUp() external {
        streamToken = new StreamToken(guardian);
    }

    function testConstructor() public view {
        assertEq(streamToken.name(), "Stream Token");
        assertEq(streamToken.symbol(), "STRK");
    }

    function testGuardian() public view {
        assertEq(streamToken.guardian(), guardian);
    }

    function testRevertIfNotGuardianMint() public {
        vm.prank(Chibyke);
        vm.expectRevert(StreamToken.StreamToken__NotGuardian.selector);
        streamToken.mint(David, 10);

        assert(streamToken.balanceOf(David) == 0);
    }

    function testRevertIfMintAmountIsZero() public {
        vm.prank(guardian);
        vm.expectRevert(StreamToken.StreamToken__MustBeMoreThanZero.selector);
        streamToken.mint(David, 0);
    }

    function testRevertIfReceiverIsZeroAddress() public {
        vm.prank(guardian);
        vm.expectRevert();
        streamToken.mint(address(0), 10);
    }

    function testMintSuccessful() public {
        vm.prank(guardian);
        streamToken.mint(David, 10);

        assert(streamToken.balanceOf(David) == 10);
    }

    function testCanSetGuardian() public {
        streamToken.setGuardian(Chibyke);

        assert(streamToken.guardian() == Chibyke);
    }

    function testOnlyOwnerCanSetGuardian() public {
        vm.prank(guardian);
        vm.expectRevert();
        streamToken.setGuardian(Chibyke);

        assert(streamToken.guardian() != Chibyke);
    }
}
