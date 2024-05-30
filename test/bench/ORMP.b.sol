// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import {Chains} from "create3-deploy/script/Chains.sol";
import "../../src/Verifier.sol";
import "../../src/ORMP.sol";
import "../../src/eco/Oracle.sol";
import "../../src/eco/Relayer.sol";

contract ORMPBenchmarkTest is Test {
    using Chains for uint256;

    ORMP ormp = ORMP(0xA72d283015c01807bc0788Bf22C1A774bDbFC8fA);
    Oracle oracle = Oracle(payable(0x3f938756ceFa33665719Eb528E581FF3f460b7C6));
    Relayer relayer = Relayer(payable(0xaC2b224c2E1eD2E8663097a361A05a72d6671C7D));

    address immutable self = address(this);
    uint256 chain1 = Chains.Darwinia;
    uint256 chain2 = Chains.Arbitrum;

    function test_send_fuzz1(bytes calldata encoded) public {
        perform_send(chain1, chain2, encoded);
    }

    function test_send_fuzz2(bytes calldata encoded) public {
        perform_send(chain2, chain1, encoded);
    }

    function test_recv_fuzz1(bytes calldata encoded) public {
        test_recv(chain1, chain2, encoded);
    }

    function test_recv_fuzz2(bytes calldata encoded) public {
        test_recv(chain2, chain1, encoded);
    }

    function test_recv(uint256 fromChainId, uint256 toChainId, bytes calldata encoded) internal {
        perform_send(fromChainId, toChainId, encoded);

        Message memory message = Message({
            channel: address(ormp),
            index: ormp.count() - 1,
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
        vm.createSelectFork(message.toChainId.toChainName());
        vm.store(address(oracle), bytes32(uint256(0)), bytes32(uint256(uint160(self))));
        assertEq(oracle.owner(), self);
        vm.prank(address(oracle.owner()));
        oracle.importMessageHash(message.fromChainId, address(ormp), message.index, hash(message));

        vm.prank(address(relayer));
        ormp.recv(message, "");
    }

    function perform_send(uint256 fromChainId, uint256 toChainId, bytes calldata encoded) public {
        vm.createSelectFork(fromChainId.toChainName());
        uint256 f = ormp.fee(toChainId, self, 0, encoded, "");
        ormp.send{value: f}(toChainId, self, 0, encoded, self, "");
    }
}
