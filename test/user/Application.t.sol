// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../../src/user/Application.sol";
import "../../src/security/ExcessivelySafeCall.sol";

contract ApplicationTest is Test {
    using ExcessivelySafeCall for address;

    UserApplication ua;
    address immutable self = address(this);

    function setUp() public {
        ua = new UserApplication(self);
    }

    function test_recv() public {
        (bool dispatchResult,) = address(ua).excessivelySafeCall(
            gasleft(), 0, 0, abi.encodePacked(ua.recv.selector, bytes32(uint256(1)), uint256(1), self)
        );
        assertEq(dispatchResult, true);
    }

    function testFail_recv() public {
        (bool dispatchResult,) = address(ua).excessivelySafeCall(
            gasleft(), 0, 0, abi.encodePacked(ua.recv.selector, bytes32(uint256(1)), uint256(1), address(1))
        );
        assertEq(dispatchResult, true);
    }
}

contract UserApplication is Application {
    constructor(address ormp) Application(ormp) {}

    function setAppConfig(address relayer, address oracle) public {}

    function recv() public view {
        bytes32 msgHash = _messageId();
        uint256 fromChainid = _fromChainId();
        address xmsgSender = _xmsgSender();
        require(msgHash == bytes32(uint256(1)));
        require(fromChainid == 1);
        require(xmsgSender == ORMP);
    }
}
