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
import {Chains} from "create3-deploy/script/Chains.sol";
import "../../src/Verifier.sol";
import "../../src/ORMP.sol";
import "../../src/eco/Oracle.sol";
import "../../src/eco/Relayer.sol";

contract ORMPBenchmarkTest is Test {
    using Chains for uint256;

    ORMP ormp = ORMP(0x009D223Aad560e72282db9c0438Ef1ef2bf7703D);
    Relayer relayer = Relayer(payable(0x003605167cd4C36063a7B63e604497e623Bb8B10));
    Oracle oracle = Oracle(payable(0x00BD655DDfA7aFeF4BB109FE1F938724527B49D8));

    bytes32 root;
    address immutable self = address(this);

    function test_send_fuzz1(bytes calldata encoded) public {
        perform_send(Chains.Crab, Chains.ArbitrumSepolia, encoded);
    }

    function test_send_fuzz2(bytes calldata encoded) public {
        perform_send(Chains.ArbitrumSepolia, Chains.Crab, encoded);
    }

    function test_recv_fuzz1(bytes calldata encoded) public {
        uint256 fromChainId = Chains.Crab;
        uint256 toChainId = Chains.ArbitrumSepolia;
        test_recv(fromChainId, toChainId, encoded);
    }

    function test_recv_fuzz2(bytes calldata encoded) public {
        uint256 fromChainId = Chains.ArbitrumSepolia;
        uint256 toChainId = Chains.Crab;
        test_recv(fromChainId, toChainId, encoded);
    }

    function test_recv(uint256 fromChainId, uint256 toChainId, bytes calldata encoded) internal {
        perform_send(fromChainId, toChainId, encoded);

        Message memory message = Message({
            channel: address(ormp),
            index: ormp.messageCount() - 1,
            fromChainId: fromChainId,
            from: self,
            toChainId: toChainId,
            to: self,
            gasLimit: 0,
            encoded: encoded
        });
        perform_recv(message);
    }

    function perform_recv(Message memory message) public {
        root = ormp.root();
        Verifier.Proof memory proof =
            Verifier.Proof({blockNumber: block.number, messageIndex: message.index, messageProof: ormp.prove()});

        vm.createSelectFork(message.toChainId.toChainName());
        vm.store(address(oracle), bytes32(uint256(0)), bytes32(uint256(uint160(self))));
        assertEq(oracle.owner(), self);
        oracle.setDapi(message.fromChainId, self);

        vm.prank(address(relayer));
        ormp.recv(message, abi.encode(proof));
    }

    function messageRoot() public view returns (bytes32) {
        return root;
    }

    function perform_send(uint256 fromChainId, uint256 toChainId, bytes calldata encoded) public {
        vm.createSelectFork(fromChainId.toChainName());
        uint256 f = ormp.fee(toChainId, self, 0, encoded, abi.encode(uint256(0)));
        ormp.send{value: f}(toChainId, self, 0, encoded, self, abi.encode(uint256(0)));
    }
}
