// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/UserConfig.sol";

contract UserConfigTest is Test {
    UserConfig config;
    address immutable self = address(this);

    function setUp() public {
        config = new UserConfig(self);
    }

    function test_constructorArgs() public {
        assertEq(config.setter(), self);
        (address relayer, address oracle) = config.defaultUC();
        assertEq(relayer, address(0));
        assertEq(oracle, address(0));
    }

    function test_changeSetter() public {
        address s = address(0x1);
        config.changeSetter(s);
        assertEq(config.setter(), s);
    }

    function testFail_changeSetter() public {
        vm.prank(address(1));
        config.changeSetter(address(1));
    }

    function test_setDefaultConfig() public {
        config.setDefaultConfig(address(1), address(2));
        (address oracle, address relayer) = config.defaultUC();
        assertEq(oracle, address(1));
        assertEq(relayer, address(2));
    }

    function testFail_setDefaultConfig() public {
        vm.prank(address(1));
        config.setDefaultConfig(address(1), address(2));
    }

    function test_setAppConfig() public {
        UC memory c = config.getAppConfig(self);
        assertEq(c.oracle, address(0));
        assertEq(c.relayer, address(0));

        config.setAppConfig(address(1), address(2));
        c = config.getAppConfig(self);
        assertEq(c.oracle, address(1));
        assertEq(c.relayer, address(2));
    }

    function test_getAppConfig() public {
        UC memory c = config.getAppConfig(self);
        assertEq(c.relayer, address(0));
        assertEq(c.oracle, address(0));

        config.setDefaultConfig(address(1), address(2));
        c = config.getAppConfig(self);
        assertEq(c.oracle, address(1));
        assertEq(c.relayer, address(2));

        config.setAppConfig(address(3), address(4));
        c = config.getAppConfig(self);
        assertEq(c.oracle, address(3));
        assertEq(c.relayer, address(4));
    }
}
