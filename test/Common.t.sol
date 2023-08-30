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
import "../src/Common.sol";

contract CommonTest is Test {
    function test_hashMessage() public {
        Message memory message = Message({
            channel: address(0xc),
            index: 0,
            fromChainId: 1,
            from: address(0x0),
            toChainId: 2,
            to: address(0x0),
            encoded: ""
        });
        assertEq0(
            hex"0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000000",
            abi.encode(message)
        );
        assertEq(bytes32(0xb641a5a085fd1455a66efb94dbabf6af79dccb25bdee35bb9cccf535925e0a19), hash(message));
    }

    function test_hashMessage_real() public {
        Message memory message = Message({
            channel: 0x00000000fec9f746a2138D9C6f42794236f3aca8,
            index: 1,
            fromChainId: 421613,
            from: 0x0f14341A7f464320319025540E8Fe48Ad0fe5aec,
            toChainId: 43,
            to: 0x000000fbfBc6954C8CBba3130b5Aee7f3Ea5108e,
            encoded: ""
        });
        assertEq(bytes32(0xec824c8e8f1f19fadc3b4532bc2925af53fdad9162eecc17342909ac8ab787f7), hash(message));
    }
}
