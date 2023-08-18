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
import "../src/Endpoint.sol";
import "../src/Verifier.sol";

contract EndpointTest is Test, Verifier {
    Endpoint endpoint;
    Message message;
    Proof proof;
    address immutable self = address(this);

    function setUp() public {
        vm.chainId(1);
        endpoint = new Endpoint();
        endpoint.setDefaultConfig(self, self);
        message = Message({
            channel: address(endpoint),
            index: 0,
            fromChainId: 1,
            from: self,
            toChainId: 2,
            to: self,
            encoded: ""
        });
    }

    function test_send() public {
        perform_send();
    }

    function perform_send() public {
        uint256 f = endpoint.fee(2, self, "", "");
        endpoint.send{value: f}(2, self, "", "");
        proof = Proof({
            blockNumber: block.number,
            messageIndex: endpoint.messageCount() - 1,
            messageProof: endpoint.prove()
        });
        vm.chainId(2);
    }

    function test_recv() public {
        perform_send();
        bool r = endpoint.recv(message, abi.encode(proof), gasleft());
        assertEq(r, false);
    }

    function test_retry() public {
        perform_send();
        bool r = endpoint.recv(message, abi.encode(proof), gasleft());
        assertEq(r, false);
        r = endpoint.retryFailedMessage(message);
        assertEq(r, false);
    }

    function test_clear() public {
        bytes32 msgHash = hash(message);
        bool failed = endpoint.fails(msgHash);
        assertEq(failed, false);
        perform_send();
        endpoint.recv(message, abi.encode(proof), gasleft());
        failed = endpoint.fails(msgHash);
        assertEq(failed, true);
        endpoint.clearFailedMessage(message);
        failed = endpoint.fails(msgHash);
        assertEq(failed, false);
    }

    function fee(uint256, address) external pure returns (uint256) {
        return 2;
    }

    function assign(bytes32) external payable {}
    function assign(bytes32, bytes calldata) external payable {}

    function fee(uint256, address, uint256, bytes calldata) external pure returns (uint256) {
        return 1;
    }

    function merkleRoot(uint256, uint256) public view override returns (bytes32) {
        return endpoint.root();
    }
}
