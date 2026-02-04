// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {ChronosToken} from "../src/ChronosToken.sol";

contract ChronosTokenTest is Test {
    ChronosToken public chronosToken;
    address dummyAddress1;
    address dummyAddress2;

    function setUp() public {
        chronosToken = new ChronosToken("Vyasa", "V", 9, 0);
        dummyAddress1 = address(123);
        dummyAddress2 = address(456);
    }

    function testOwner() public {
        assertEq(address(this), chronosToken.getOwner());
    }

    function testName() public {
        assertEq("Vyasa", chronosToken.name());
    }

    function testSymbol() public {
        assertEq("V", chronosToken.symbol());
    }

    function testDecimal() public {
        assertEq(9, chronosToken.decimals());
    }

    function testInitialTotalSupply() public {
        assertEq(0, chronosToken.totalSupply());
    }

    function testMinting() public {
        chronosToken.mintTo(dummyAddress1, 1000000000);

        assertEq(1000000000, chronosToken.balanceOf(dummyAddress1));
    }

    function testMintingFail() public {
        chronosToken.mintTo(dummyAddress1, 1000000000);

        assertNotEq(100000, chronosToken.balanceOf(dummyAddress1));

        vm.prank(dummyAddress1);
        chronosToken.mintTo(dummyAddress1, 1000000000);

        assertEq(1000000000, chronosToken.balanceOf(dummyAddress1));
        assertNotEq(2000000000, chronosToken.balanceOf(dummyAddress1));
    }

    function testAllowanceAndTranferFrom() public {
        chronosToken.mintTo(dummyAddress1, 5000000000);

        vm.prank(dummyAddress1);
        chronosToken.approve(dummyAddress2, 1000000000);

        vm.prank(dummyAddress2);
        chronosToken.transferFrom(dummyAddress1, dummyAddress2, 1000000000);

        assertEq(chronosToken.balanceOf(dummyAddress1), 4000000000);
        assertEq(chronosToken.balanceOf(dummyAddress2), 1000000000);
        assertNotEq(chronosToken.balanceOf(dummyAddress1), 3500000000);
        assertNotEq(chronosToken.balanceOf(dummyAddress2), 500000000);
    }

    function testTransfer() public {
        chronosToken.mintTo(dummyAddress1, 3000000000);

        vm.prank(dummyAddress1);
        chronosToken.transfer(dummyAddress2, 1000000000);

        assertEq(chronosToken.balanceOf(dummyAddress1), 2000000000);
        assertEq(chronosToken.balanceOf(dummyAddress2), 1000000000);
    }
}
