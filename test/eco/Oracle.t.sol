// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../../src/eco/Oracle.sol";

contract OracleTest is Test {
    Oracle oracle;
    address immutable self = address(this);

    receive() external payable {}

    function setUp() public {
        oracle = new Oracle(self, self);
        oracle.setApproved(self, true);
    }

    function test_constructorArgs() public {
        assertEq(oracle.PROTOCOL(), self);
        assertEq(oracle.owner(), self);
    }

    function test_withdraw() public {
        vm.deal(address(oracle), 1);
        oracle.withdraw(self, 1);
    }

    function testFail_withdraw() public {
        oracle.withdraw(self, 1);
    }

    function test_changeOwner() public {
        address s = address(0x1);
        oracle.changeOwner(s);
        assertEq(oracle.owner(), s);
    }

    function testFail_changeOwner() public {
        vm.prank(address(1));
        oracle.changeOwner(address(1));
    }

    function test_setFee() public {
        oracle.setFee(1, 1);
        assertEq(oracle.fee(1, address(1)), 1);
    }

    function testFail_setFee() public {
        vm.prank(address(1));
        oracle.setFee(1, 1);
    }

    function test_hashOf() public {
        bytes32 r = oracle.hashOf(1, self, 1);
        assertEq(r, bytes32(uint256(1)));
    }

    function hashLookup(address, bytes32) external pure returns (bytes32) {
        return bytes32(uint256(1));
    }
}
