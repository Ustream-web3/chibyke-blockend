// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {StreamToken} from "../../src/StreamToken.sol";

contract TestStreamToken is Test {
    StreamToken streamToken;

    function setUp() external {
        streamToken = new StreamToken();
    }

    function testConstructor() public view {
        assertEq(streamToken.name(), "Stream Token");
        assertEq(streamToken.symbol(), "STRK");
    }
}
