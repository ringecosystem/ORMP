// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/ORMP.sol";
import "../src/Verifier.sol";

contract EIP150Test is Test, Verifier {
    ORMP ormp;
    Message m;
    address immutable self = address(this);

    receive() external payable {}

    function setUp() public {
        vm.chainId(1);
        ormp = new ORMP(self);
        ormp.setDefaultConfig(self, self);
    }

    function loop() public pure {
        while (true) {}
    }

    function test_couldNotCallContractFallbackFunc() public {
        m = Message({
            channel: address(ormp),
            index: 0,
            fromChainId: 1,
            from: self,
            toChainId: 2,
            to: self,
            gasLimit: 0,
            encoded: ""
        });
        uint256 f = ormp.fee(m.toChainId, m.from, m.gasLimit, m.encoded, "");
        ormp.send{value: f}(m.toChainId, m.to, m.gasLimit, m.encoded, self, "");
        vm.chainId(m.toChainId);

        bool r = ormp.recv{gas: 50000}(m, "");
        assertEq(r, false);
    }

    function testFail_eip150() public {
        m = Message({
            channel: address(ormp),
            index: 0,
            fromChainId: 1,
            from: self,
            toChainId: 2,
            to: self,
            gasLimit: 300000,
            encoded: abi.encodeWithSelector(this.loop.selector)
        });
        uint256 f = ormp.fee(m.toChainId, m.from, m.gasLimit, m.encoded, "");
        ormp.send{value: f}(m.toChainId, m.to, m.gasLimit, m.encoded, self, "");
        vm.chainId(m.toChainId);

        bool r = ormp.recv{gas: 290000}(m, "");
        assertEq(r, false);
    }

    function test_eip150() public {
        m = Message({
            channel: address(ormp),
            index: 0,
            fromChainId: 1,
            from: self,
            toChainId: 2,
            to: self,
            gasLimit: 100,
            encoded: abi.encodeWithSelector(this.loop.selector)
        });
        uint256 f = ormp.fee(m.toChainId, m.from, m.gasLimit, m.encoded, "");
        ormp.send{value: f}(m.toChainId, m.to, m.gasLimit, m.encoded, self, "");
        vm.chainId(m.toChainId);

        bool r = ormp.recv{gas: 50000}(m, "");
        assertEq(r, false);
    }

    function fee(uint256, address) external pure returns (uint256) {
        return 2;
    }

    function fee(uint256, address, uint256, bytes calldata, bytes calldata) external pure returns (uint256) {
        return 1;
    }

    function hashOf(uint256, address, uint256) public view override returns (bytes32) {
        return hash(m);
    }
}
