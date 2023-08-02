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

import "ds-test/test.sol";
import "../src/Channel.sol";
import "../src/Verifier.sol";

contract ChannelTest is DSTest, Verifier {
    Channel channel;
    address self;

    bytes32[32] zeroHashes;

    function setUp() public {
        self = address(this);
        channel = new Channel(self, self);
        for (uint height = 0; height < 31; height++)
            zeroHashes[height + 1] = keccak256(abi.encodePacked(zeroHashes[height], zeroHashes[height]));
    }

    function testConstructorArgs() public {
        assertEq(channel.ENDPOINT(), self);
        assertEq(channel.CONFIG(), self);
        assertEq(channel.LOCAL_CHAINID(), 31337);
        assertEq(channel.root(), keccak256(abi.encodePacked(zeroHashes[31], zeroHashes[31])));
        assertEq(channel.messageSize(), 0);
        bytes32[32] memory branch = channel.imtBranch();
        for (uint height = 0; height < 32; height++) {
            assertEq(branch[height], bytes32(0));
        }
    }

    function testSendMessage() public {
        channel.sendMessage(self, 2, self, "");
    }

    function testRecvMessage() public {
        bytes32 msgHash = channel.sendMessage(self, channel.LOCAL_CHAINID(), self, "");

        Message memory message = Message({
            channel: address(channel),
            index: 0,
            fromChainId: channel.LOCAL_CHAINID(),
            from: self,
            toChainId: channel.LOCAL_CHAINID(),
            to: self,
            encoded: ""
        });
        assertEq(msgHash, hash(message));
        Proof memory proof = Proof({
            blockNumber: block.number,
            messageIndex: 0,
            messageProof: zeroHashes
        });
        channel.recvMessage(message, abi.encode(proof));
    }

    function recv(Message calldata) external pure returns (bool) { return true; }

    function getAppConfig(address) external view returns (Config memory) {
        return Config(self, self);
    }

    function merkleRoot(uint256, uint256) public view override returns (bytes32) {
        return channel.root();
    }
}
