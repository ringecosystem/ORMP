// This file is part of Darwinia.
// Copyright (C) 2018-2022 Darwinia Network
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
import "../src/Endpoint.sol";

contract EndpointTest is Test {
    Endpoint endpoint;
    Message message;
    address immutable self = address(this);

    function setUp() public {
        vm.chainId(1);
        endpoint = new Endpoint(self, self);
        message =
            Message({channel: address(0xc), index: 0, fromChainId: 1, from: self, toChainId: 2, to: self, encoded: ""});
    }

    function test_constructorArgs() public {
        assertEq(endpoint.CONFIG(), self);
        assertEq(endpoint.CHANNEL(), self);
    }

    function test_send() public {
        uint256 f = endpoint.fee(2, self, "", "");
        endpoint.send{value: f}(2, self, "", "");
    }

    function test_recv() public {
        bool r = endpoint.recv(message);
        assertEq(r, false);
    }

    function test_retry() public {
        bool r = endpoint.recv(message);
        assertEq(r, false);
        r = endpoint.retryFailedMessage(message);
        assertEq(r, false);
    }

    function test_clear() public {
        bytes32 msgHash = hash(message);
        bool failed = endpoint.fails(msgHash);
        assertEq(failed, false);
        endpoint.recv(message);
        failed = endpoint.fails(msgHash);
        assertEq(failed, true);
        endpoint.clearFailedMessage(message);
        failed = endpoint.fails(msgHash);
        assertEq(failed, false);
    }

    function fee(uint256, address) external pure returns (uint256) {
        return 2;
    }

    function assign(bytes32, uint256, address) external payable returns (uint256) {
        return 2;
    }

    function fee(uint256, address, uint256, bytes calldata) external pure returns (uint256) {
        return 1;
    }

    function assign(bytes32, uint256, address, uint256, bytes calldata) external payable returns (uint256) {
        return 1;
    }

    function getAppConfig(address) external view returns (Config memory) {
        return Config(self, self);
    }

    function sendMessage(address, uint256, address, bytes calldata) external pure returns (bytes32) {
        return bytes32(uint256(1));
    }
}
