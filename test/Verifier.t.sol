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
import "../src/Verifier.sol";
import "../src/imt/IncrementalMerkleTree.sol";

contract VerifierTest is Test, Verifier {
    using IncrementalMerkleTree for IncrementalMerkleTree.Tree;

    IncrementalMerkleTree.Tree imt;
    bytes32[32] zeroHashes;

    function setUp() public {
        for (uint256 height = 0; height < 31; height++) {
            zeroHashes[height + 1] = keccak256(abi.encodePacked(zeroHashes[height], zeroHashes[height]));
        }
    }

    function test_verifyMessageProof() public {
        bytes32 msgHash = bytes32(uint256(1));
        imt.insert(msgHash);
        Proof memory proof = Proof({blockNumber: block.number, messageIndex: 0, messageProof: zeroHashes});
        bool r = this.verifyMessageProof(1, msgHash, abi.encode(proof));
        assertEq(r, true);
    }

    function merkleRoot(uint256, uint256) public view override returns (bytes32) {
        return imt.root();
    }
}
