// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {console2 as console} from "forge-std/console2.sol";

import {Chains} from "../Chains.sol";
import {ScriptTools} from "../ScriptTools.sol";

interface III {
    function isApproved(address operator) external view returns (bool);
    function setApproved(address operator, bool approve) external;

    function setFee(uint256 chainId, uint256 fee_) external;
    function setDstPrice(uint256 chainId, uint128 dstPriceRatio, uint128 dstGasPriceInWei) external;
    function setDstConfig(uint256 chainId, uint64 baseGas, uint64 gasPerByte) external;

    function fee(uint256 toChainId, address ua) external view returns (uint256);
    function fee(uint256 toChainId, address ua, uint256 size, bytes calldata params) external view returns (uint256);
}

contract Fee is Script {
    using stdJson for string;
    using ScriptTools for string;
    using Chains for uint256;

    string instanceId;
    string config;
    string deployedContracts;
    address dao;

    function name() public pure returns (string memory) {
        return "Fee";
    }

    function setUp() public {
        uint256 chainId = vm.envOr("CHAIN_ID", block.chainid);
        createSelectFork(chainId);
        console.log("Connected to network with chainid %s", chainId);

        instanceId = vm.envOr("INSTANCE_ID", string("fee.c"));
        vm.setEnv("FOUNDRY_ROOT_CHAINID", vm.toString(block.chainid));
        vm.setEnv("FOUNDRY_EXPORTS_OVERWRITE_LATEST", vm.toString(true));
        config = ScriptTools.readInput(instanceId);
        deployedContracts = ScriptTools.readOutput("deploy.a");

        dao = deployedContracts.readAddress(".DAO");

        console.log("Script: %s", name());
        console.log("Context: %s", getContext());
    }

    function run(uint256 chainId) public {
        require(dao == msg.sender, "!dao");

        setOracleFee(chainId);
        setRelayerFee(chainId);
    }

    function setOracleFee(uint256 chainId) public broadcast {
        string memory key = string.concat(".ORACLE", ".", vm.toString(chainId), ".fee");
        uint256 fee = config.readUint(key);
        address oracle = deployedContracts.readAddress(".ORACLE");

        bool approved = III(oracle).isApproved(dao);
        if (!approved) {
            III(oracle).setApproved(dao, true);
        }
        III(oracle).setFee(chainId, fee);
        require(III(oracle).fee(chainId, address(0)) == fee);
    }

    function setRelayerFee(uint256 chainId) public broadcast {
        string memory prefix = string.concat(".RELAYER", ".", vm.toString(chainId));
        uint128 dstPriceRatio = uint128(config.readUint(string.concat(prefix, ".dstPriceRatio")));
        uint128 dstGasPriceInWei = uint128(config.readUint(string.concat(prefix, ".dstGasPriceInWei")));
        uint64 baseGas = uint64(config.readUint(string.concat(prefix, ".baseGas")));
        uint64 gasPerByte = uint64(config.readUint(string.concat(prefix, ".gasPerByte")));

        address relayer = deployedContracts.readAddress(".RELAYER");
        bool approved = III(relayer).isApproved(dao);
        if (!approved) {
            III(relayer).setApproved(dao, true);
        }
        III(relayer).setDstPrice(chainId, dstPriceRatio, dstGasPriceInWei);
        III(relayer).setDstConfig(chainId, baseGas, gasPerByte);
    }

    modifier broadcast() {
        vm.startBroadcast();
        _;
        vm.stopBroadcast();
    }

    function getContext() internal returns (string memory) {
        string memory context = vm.envOr("DEPLOYMENT_CONTEXT", string(""));
        if (bytes(context).length > 0) {
            return context;
        }

        uint256 chainid = vm.envOr("CHAIN_ID", block.chainid);
        return chainid.toChainName();
    }

    function createSelectFork(uint256 chainid) public {
        vm.createSelectFork(chainid.toChainName());
    }
}
