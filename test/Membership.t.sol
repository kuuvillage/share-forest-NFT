// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Membership} from "../src/Membership.sol";

contract MembershipTest is Test {
    Membership public membership;

    function setUp() public {
        membership = new Membership();
        membership.setNumber(0);
    }

    function test_Increment() public {
        membership.increment();
        assertEq(membership.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        membership.setNumber(x);
        assertEq(membership.number(), x);
    }
}
