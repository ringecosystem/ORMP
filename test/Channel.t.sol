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
import "../src/Channel.sol";
import "../src/Verifier.sol";

contract ChannelTest is Test, Verifier {
    Channel channel;
    address immutable self = address(this);

    bytes32[32] zeroHashes;

    function setUp() public {
        vm.chainId(1);
        channel = new Channel(self, self);
        for (uint256 height = 0; height < 31; height++) {
            zeroHashes[height + 1] = keccak256(abi.encodePacked(zeroHashes[height], zeroHashes[height]));
        }
    }

    function test_constructorArgs() public {
        assertEq(channel.CONFIG(), self);
        assertEq(channel.ENDPOINT(), self);
        assertEq(channel.LOCAL_CHAINID(), 1);
        assertEq(channel.root(), keccak256(abi.encodePacked(zeroHashes[31], zeroHashes[31])));
        assertEq(channel.messageSize(), 0);
        bytes32[32] memory branch = channel.imtBranch();
        for (uint256 height = 0; height < 32; height++) {
            assertEq(branch[height], bytes32(0));
        }
    }

    function test_sendMessage() public {
        channel.sendMessage(self, 2, self, "");
    }

    function testFail_sendMessage_notCrossChain() public {
        channel.sendMessage(self, 1, self, "");
    }

    function testFail_sendMessage_notEndpoint() public {
        vm.prank(address(0xc));
        channel.sendMessage(self, 2, self, "");
    }

    function test_recvMessage() public {
        bytes32 msgHash = channel.sendMessage(self, 2, self, "");

        Message memory message = Message({
            channel: address(channel),
            index: 0,
            fromChainId: channel.LOCAL_CHAINID(),
            from: self,
            toChainId: 2,
            to: self,
            encoded: ""
        });
        assertEq(msgHash, hash(message));
        Proof memory proof = Proof({blockNumber: block.number, messageIndex: 0, messageProof: zeroHashes});
        vm.chainId(2);
        channel.recvMessage(message, abi.encode(proof));
    }

    function recv(Message calldata) external pure returns (bool) {
        return true;
    }

    function getAppConfig(address) external view returns (Config memory) {
        return Config(self, self);
    }

    function merkleRoot(uint256, uint256) public view override returns (bytes32) {
        return channel.root();
    }
}
