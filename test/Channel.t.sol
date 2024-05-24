// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/Channel.sol";
import "../src/Verifier.sol";

contract ChannelTest is Test, Verifier {
    ChannelWrapper channel;
    address immutable self = address(this);

    bytes32 msgHash;

    function setUp() public {
        vm.chainId(1);
        channel = new ChannelWrapper(self);
        channel.setDefaultConfig(self, self);
    }

    function test_constructorArgs() public {
        assertEq(channel.LOCAL_CHAINID(), 1);
        assertEq(channel.count(), 0);
    }

    function test_sendMessage() public {
        channel.sendMessage(self, 2, self, 0, "");
    }

    function testFail_sendMessage_notCrossChain() public {
        channel.sendMessage(self, 1, self, 0, "");
    }

    function test_recvMessage() public {
        msgHash = channel.sendMessage(self, 2, self, 0, "");

        Message memory message = Message({
            channel: address(channel),
            index: 0,
            fromChainId: channel.LOCAL_CHAINID(),
            from: self,
            toChainId: 2,
            to: self,
            gasLimit: 0,
            encoded: ""
        });
        assertEq(msgHash, hash(message));
        vm.chainId(2);
        channel.recvMessage(message, "");
    }

    function test_recvMessage_fuzz() public {
        for (uint256 i = 0; i < 100; i++) {
            vm.chainId(1);
            uint256 index = channel.count();
            msgHash = channel.sendMessage(self, 2, self, 0, "");
            Message memory message = Message({
                channel: address(channel),
                index: index,
                fromChainId: 1,
                from: self,
                toChainId: 2,
                to: self,
                gasLimit: 0,
                encoded: ""
            });
            assertEq(msgHash, hash(message));
            vm.chainId(2);
            channel.recvMessage(message, "");
        }
    }

    function hashOf(uint256, address, uint256) public view override returns (bytes32) {
        return msgHash;
    }
}

contract ChannelWrapper is Channel {
    constructor(address dao) Channel(dao) {}

    function sendMessage(address from, uint256 toChainId, address to, uint256 gasLimit, bytes calldata encoded)
        public
        returns (bytes32)
    {
        return _send(from, toChainId, to, gasLimit, encoded);
    }

    function recvMessage(Message calldata message, bytes calldata proof) public {
        _recv(message, proof);
    }
}
