// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {Test} from "forge-std/Test.sol";
import {console2 as console} from "forge-std/console2.sol";
import {stdJson} from "forge-std/StdJson.sol";

import {Chains} from "./Chains.sol";
import {ScriptTools} from "./ScriptTools.sol";

import "../../src/Endpoint.sol";
import {Relayer} from "../../src/eco/Relayer.sol";
import {Oracle} from "../../src/eco/Oracle.sol";

interface III {
    function ENDPOINT() external view returns (address);
    function isApproved(address operator) external view returns (bool);
    function setApproved(address operator, bool approve) external;
    function owner() external view returns (address);
    function changeOwner(address owner_) external;
    function setter() external view returns (address);
    function changeSetter(address setter_) external;
}

/// @title Deploy
/// @notice Script used to deploy a ORMP protocol. The entire protocol is deployed within the `run` function.
///         To add a new contract to the protocol, add a public function that deploys that individual contract.
///         Then add a call to that function inside of `run`.
contract Deploy is Script {
    using stdJson for string;
    using ScriptTools for string;
    using Chains for uint256;

    address immutable SAFE_CREATE2_ADDR = 0x914d7Fec6aaC8cd542e72Bca78B30650d45643d7;
    bytes32 immutable ENDPOINT_SALT = 0x8d4710aeefe981796a685a8e13aa114a594334b7e58aee4be59393a377a33ad6;
    address immutable ENDPOINT_ADDR = 0x0000008BA49A1eeaFe5A771f4bEEa98B0a54Be51;
    bytes32 immutable ORACLE_SALT = 0xf48db30bdf790ed067a2390bfd0f53871ca5a19617f1fc0defdb78614226ddeb;
    address immutable ORACLE_ADDR = 0x000000F352eDC7fbf3Abdc98CfEB7cdb11b0d47f;
    bytes32 immutable RELAYER_SALT = 0x99dc755fa10cf0bc8e0ced6a3b8b7997fc762617ff7c3ab45b94091236010d06;
    address immutable RELAYER_ADDR = 0x00000037990175dCe30a082ba56a3e62651b1793;

    string config;
    string instanceId;
    string outputName;
    address deployer;
    address dao;
    address oracleOperator;
    address relayerOperator;

    /// @notice The name of the script, used to ensure the right deploy artifacts
    ///         are used.
    function name() public pure returns (string memory) {
        return "Deploy";
    }

    function setUp() public {
        uint256 chainId = vm.envOr("CHAIN_ID", block.chainid);
        createSelectFork(chainId);
        console.log("Connected to network with chainid %s", chainId);

        instanceId = vm.envOr("INSTANCE_ID", string("deploy.c"));
        outputName = "deploy.a";
        vm.setEnv("FOUNDRY_ROOT_CHAINID", vm.toString(block.chainid));
        vm.setEnv("FOUNDRY_EXPORTS_OVERWRITE_LATEST", vm.toString(true));
        config = ScriptTools.readInput(instanceId);

        deployer = config.readAddress(".DEPLOYER");
        dao = config.readAddress(".DAO");
        oracleOperator = config.readAddress(".ORACLE_OPERATOR");
        relayerOperator = config.readAddress(".RELAYER_OPERATOR");

        console.log("Deploying from %s", name());
        console.log("Deployment context: %s", getDeploymentContext());
    }

    /// @notice Deploy all of the contracts
    function run() public {
        require(deployer == msg.sender, "!deployer");

        address endpoint = deployEndpoint();

        address oracle = deployOralce(endpoint);
        address relayer = deployRelayer(endpoint);

        setConfig(endpoint, oracle, relayer);

        ScriptTools.exportContract(outputName, "DAO", dao);
        ScriptTools.exportContract(outputName, "ENDPOINT", endpoint);
        ScriptTools.exportContract(outputName, "ORACLE", oracle);
        ScriptTools.exportContract(outputName, "RELAYER", relayer);
    }

    function _deploy(bytes32 salt, bytes memory initCode) public returns (address) {
        bytes memory data = bytes.concat(salt, initCode);
        (, bytes memory addr) = SAFE_CREATE2_ADDR.call(data);
        return payable(address(uint160(bytes20(addr))));
    }

    /// @notice Deploy the Endpoint
    function deployEndpoint() public broadcast returns (address) {
        bytes memory byteCode = type(Endpoint).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer));
        address endpoint = _deploy(ENDPOINT_SALT, initCode);
        require(endpoint == ENDPOINT_ADDR, "!endpoint");
        require(III(endpoint).setter() == deployer, "!deployer");
        console.log("Endpoint   deployed at %s", endpoint);
        return endpoint;
    }

    /// @notice Deploy the Oracle
    function deployOralce(address endpoint) public broadcast returns (address) {
        bytes memory byteCode = type(Oracle).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer, endpoint));
        address oracle = _deploy(ORACLE_SALT, initCode);
        require(oracle == ORACLE_ADDR, "!oracle");

        require(III(oracle).owner() == deployer);
        require(III(oracle).ENDPOINT() == endpoint);
        console.log("Oracle     deployed at %s", oracle);
        return oracle;
    }

    /// @notice Deploy the Relayer
    function deployRelayer(address endpoint) public broadcast returns (address) {
        bytes memory byteCode = type(Relayer).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer, endpoint));
        address relayer = _deploy(RELAYER_SALT, initCode);
        require(relayer == RELAYER_ADDR, "!relayer");

        require(III(relayer).owner() == deployer);
        require(III(relayer).ENDPOINT() == endpoint);
        console.log("Relayer    deployed at %s", relayer);
        return relayer;
    }

    /// @notice Set the protocol config
    function setConfig(address endpoint, address oracle, address relayer) public broadcast {
        Endpoint(endpoint).setDefaultConfig(oracle, relayer);
        Config memory cfg = Endpoint(endpoint).getDefaultConfig();
        require(cfg.oracle == oracle, "!oracle");
        require(cfg.relayer == relayer, "!relayer");

        III(oracle).setApproved(oracleOperator, true);
        require(III(oracle).isApproved(oracleOperator), "!o-operator");
        III(relayer).setApproved(relayerOperator, true);
        require(III(relayer).isApproved(relayerOperator), "!r-operator");

        III(endpoint).changeSetter(dao);
        require(III(endpoint).setter() == dao, "!dao");

        III(oracle).changeOwner(dao);
        require(III(oracle).owner() == dao, "!dao");

        III(relayer).changeOwner(dao);
        require(III(relayer).owner() == dao, "!dao");
    }

    /// @notice Modifier that wraps a function in broadcasting.
    modifier broadcast() {
        vm.startBroadcast();
        _;
        vm.stopBroadcast();
    }

    /// @notice The context of the deployment is used to namespace the artifacts.
    ///         An unknown context will use the chainid as the context name.
    function getDeploymentContext() internal returns (string memory) {
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
