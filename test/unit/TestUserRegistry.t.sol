// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {UserRegistry} from "../../src/UserRegistry.sol";

contract TestUserRegistry is Test {
    UserRegistry registry;

    address userOne = makeAddr("userOne");
    address userTwo = makeAddr("userTwo");
    address userThree = makeAddr("userThree");
    address userFour = makeAddr("userFour");
    address userFive = makeAddr("userFive");

    function setUp() external {
        registry = new UserRegistry();
    }
}
