// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "ds-test/test.sol";

import "./Omp.sol";

contract OmpTest is DSTest {
    Omp omp;

    function setUp() public {
        omp = new Omp();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
