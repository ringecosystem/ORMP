// This file is part of Darwinia.
// Copyright (C) 2018-2023 Darwinia Network
// SPDX-License-Identifier: GPL-3.0
//
// Darwinia is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Darwinia is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Darwinia. If not, see <https://www.gnu.org/licenses/>.

pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../../src/eco/Oracle.sol";

contract OracleTest is Test {
    Oracle oracle;
    address immutable self = address(this);

    receive() external payable {}

    function setUp() public {
        oracle = new Oracle(self);
    }

    function test_constructorArgs() public {
        assertEq(oracle.ENDPOINT(), self);
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

    function test_setDapi() public {
        oracle.setDapi(1, address(1));
        assertEq(oracle.dapiOf(1), address(1));
    }

    function testFail_setDapi() public {
        vm.prank(address(1));
        oracle.setDapi(1, address(1));
    }

    function test_assign() public {
        oracle.setFee(1, 1);
        oracle.assign{value: 1}(bytes32(0), 1, self);
    }

    function test_merkleRoot() public {
        oracle.setDapi(1, self);
        bytes32 r = oracle.merkleRoot(1, 1);
        assertEq(r, bytes32(uint256(1)));
    }

    function messageRootOf(uint256) external pure returns (bytes32) {
        return bytes32(uint256(1));
    }
}
