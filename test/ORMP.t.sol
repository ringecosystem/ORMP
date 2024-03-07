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
import "../src/ORMP.sol";
import "../src/Verifier.sol";

contract ORMPTest is Test, Verifier {
    ORMP ormp;
    Message message;
    Proof proof;
    address immutable self = address(this);

    function setUp() public {
        vm.chainId(1);
        ormp = new ORMP(self);
        ormp.setDefaultConfig(self, self);
        message = Message({
            channel: address(ormp),
            index: 0,
            fromChainId: 1,
            from: self,
            toChainId: 2,
            to: self,
            gasLimit: 0,
            encoded: ""
        });
    }

    function test_send() public {
        perform_send();
    }

    function perform_send() public {
        uint256 f = ormp.fee(2, self, 0, "", "");
        ormp.send{value: f}(2, self, 0, "", self, "");
        proof = Proof({blockNumber: block.number, messageIndex: ormp.messageCount() - 1, messageProof: ormp.prove()});
        vm.chainId(2);
    }

    function test_Refunds() public {
        uint256 f = ormp.fee(2, self, 0, "", "");
        ormp.send{value: f+5}(2, self, 0, "", address(5), "");
        assertEq(address(5).balance, 5);
    }

    function testFail_sendSameMsg() public {
        uint256 f1 = ormp.fee(2, self, 0, "", "");
        bytes32 msgHash1 = ormp.send{value: f1}(2, self, 0, "", self, "");
        
        uint256 f2 = ormp.fee(2, self, 0, "", "");
        bytes32 msgHash2 = ormp.send{value: f2}(2, self, 0, "", self, "");
        vm.chainId(2);

        assertEq(msgHash1, msgHash2);
    }

    function testFail_SendWithZeroNativeFee() public {
        ormp.send{value: 0}(2, self, 0, "", address(5), "");
        proof = Proof({blockNumber: block.number, messageIndex: ormp.messageCount() - 1, messageProof: ormp.prove()});
        vm.chainId(2);
    }

    function test_recv() public {
        perform_send();
        bool r = ormp.recv(message, abi.encode(proof));
        assertEq(r, false);
    }

    function testFail_recvTwice() public {
        perform_send();
        bool r = ormp.recv(message, abi.encode(proof));
        assertEq(r, false);
        ormp.recv(message, abi.encode(proof));
    }

    function test_failedMsgDispactedSuccess_PoC() public {
        uint256 f = ormp.fee(2, self, 0, "", "");
        ormp.send{value: f}(2, self, 0, "", self, "");
        proof = Proof({blockNumber: block.number, messageIndex: ormp.messageCount() - 1, messageProof: ormp.prove()});
        
        vm.chainId(2);

        bool returnValue = ormp.recv(message, abi.encode(proof));
        assertEq(returnValue, false);                /// msg delivery failed
        assertEq(ormp.dones(hash(message)), true);   /// but marked dispatched
    }

    function fee(uint256, address) external pure returns (uint256) {
        return 2;
    }

    function assign(bytes32) external payable {}
    function assign(bytes32, bytes calldata) external payable {}

    function fee(uint256, address, uint256, bytes calldata, bytes calldata) external pure returns (uint256) {
        return 1;
    }

    function merkleRoot(uint256, uint256) public view override returns (bytes32) {
        return ormp.root();
    }
}
