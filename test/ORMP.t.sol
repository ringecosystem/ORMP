// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/ORMP.sol";
import "../src/Verifier.sol";

contract ORMPTest is Test, Verifier {
    ORMP ormp;
    Message message;
    address immutable self = address(this);

    receive() external payable {}

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
        vm.chainId(2);
    }

    function test_refunds() public {
        uint256 f = ormp.fee(2, self, 0, "", "");
        ormp.send{value: f + 5}(2, self, 0, "", address(5), "");
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

    function testFail_sendWithZeroNativeFee() public {
        ormp.send{value: 0}(2, self, 0, "", address(5), "");
        vm.chainId(2);
    }

    function test_recv() public {
        perform_send();
        bool r = ormp.recv(message, "");
        assertEq(r, false);
    }

    function testFail_recvTwice() public {
        perform_send();
        bool r = ormp.recv(message, "");
        assertEq(r, false);
        ormp.recv(message, "");
    }

    function test_failedMsgDispactedSuccess_PoC() public {
        uint256 f = ormp.fee(2, self, 0, "", "");
        ormp.send{value: f}(2, self, 0, "", self, "");

        vm.chainId(2);

        bool returnValue = ormp.recv(message, "");
        /// msg delivery failed
        assertEq(returnValue, false);
        /// but marked dispatched
        assertEq(ormp.dones(hash(message)), true);
    }

    function fee(uint256, address) external pure returns (uint256) {
        return 2;
    }

    function fee(uint256, address, uint256, bytes calldata, bytes calldata) external pure returns (uint256) {
        return 1;
    }

    function hashOf(uint256, address, uint256) public view override returns (bytes32) {
        return hash(message);
    }
}
