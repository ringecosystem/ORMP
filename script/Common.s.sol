// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {console2 as console} from "forge-std/console2.sol";

import {Chains} from "./Chains.sol";
import {ScriptTools} from "./ScriptTools.sol";

abstract contract Common is Script {
    using stdJson for string;
    using ScriptTools for string;
    using Chains for uint256;

    address immutable SAFE_CREATE2_ADDR = 0x914d7Fec6aaC8cd542e72Bca78B30650d45643d7;

    /// @notice Modifier that wraps a function in broadcasting.
    modifier broadcast() {
        vm.startBroadcast();
        _;
        vm.stopBroadcast();
    }

    function name() public pure virtual returns (string memory);

    function setUp() public virtual {
        uint256 chainId = vm.envOr("CHAIN_ID", block.chainid);
        createSelectFork(chainId);
        console.log("Connected to network with chainid %s", chainId);

        vm.setEnv("FOUNDRY_ROOT_CHAINID", vm.toString(block.chainid));
        vm.setEnv("FOUNDRY_EXPORTS_OVERWRITE_LATEST", vm.toString(true));

        console.log("Script %s", name());
        console.log("Context: %s", context());
    }

    function createSelectFork(uint256 chainid) public {
        vm.createSelectFork(chainid.toChainName());
    }

    /// @notice The context of the deployment is used to namespace the artifacts.
    ///         An unknown context will use the chainid as the context name.
    function context() internal returns (string memory) {
        string memory c = vm.envOr("DEPLOYMENT_CONTEXT", string(""));
        if (bytes(c).length > 0) {
            return c;
        }

        uint256 chainid = vm.envOr("CHAIN_ID", block.chainid);
        return chainid.toChainName();
    }

    function _deploy(bytes32 salt, bytes memory initCode) public returns (address) {
        bytes memory data = bytes.concat(salt, initCode);
        (, bytes memory addr) = SAFE_CREATE2_ADDR.call(data);
        return address(uint160(bytes20(addr)));
    }
}
