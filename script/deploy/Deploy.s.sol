// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {Test} from "forge-std/Test.sol";
import {console2 as console} from "forge-std/console2.sol";
import {stdJson} from "forge-std/StdJson.sol";

import {Deployer} from "./Deployer.sol";
import {ScriptTools} from "./ScriptTools.sol";

import "../../src/interfaces/IUserConfig.sol";
import {Factory} from "../../src/Factory.sol";
import {Channel} from "../../src/Channel.sol";
import {Endpoint} from "../../src/Endpoint.sol";
import {UserConfig} from "../../src/UserConfig.sol";
import {Relayer} from "../../src/eco/Relayer.sol";
import {Oracle} from "../../src/eco/Oracle.sol";

interface IOperator {
    function isApproved(address operator) external view returns (bool);
    function setApproved(address operator, bool approve) external;
}

/// @title Deploy
/// @notice Script used to deploy a ORMP protocol. The entire protocol is deployed within the `run` function.
///         To add a new contract to the protocol, add a public function that deploys that individual contract.
///         Then add a call to that function inside of `run`. Be sure to call the `save` function after each
///         deployment so that `hardhat-deploy` style artifacts can be generated using a call to `sync()`.
contract Deploy is Deployer {
    using stdJson for string;
    using ScriptTools for string;

    address immutable SAFE_CREATE2 = 0x914d7Fec6aaC8cd542e72Bca78B30650d45643d7;

    string config;
    string instanceId;
    string outputName;
    address deployer;
    bytes32 salt;
    address oracleOperator;
    address relayerOperator;

    /// @notice The name of the script, used to ensure the right deploy artifacts
    ///         are used.
    function name() public pure override returns (string memory) {
        return "Deploy";
    }

    function setUp() public override {
        super.setUp();

        instanceId = vm.envOr("INSTANCE_ID", string("deploy.c"));
        outputName = "deploy.a";
        vm.setEnv("FOUNDRY_ROOT_CHAINID", vm.toString(block.chainid));
        vm.setEnv("FOUNDRY_EXPORTS_OVERWRITE_LATEST", vm.toString(true));
        config = ScriptTools.readInput(instanceId);

        salt = config.readBytes32(".SALT");
        oracleOperator = config.readAddress(".ORACLE_OPERATOR");
        relayerOperator = config.readAddress(".RELAYER_OPERATOR");

        console.log("Deploying from %s", deployScript);
        console.log("Deployment context: %s", deploymentContext);
    }

    /// @notice Deploy all of the contracts
    function run() public {
        deployer = msg.sender;

        address factory = deployFactory();

        (address uc, address channel, address endpoint) = deployProtocol(factory);

        address oracle = deployOralce(endpoint);
        address relayer = deployRelayer(endpoint, channel);

        // setConfig(uc, oracle, relayer);

        ScriptTools.exportContract(outputName, "DEPLOYER", deployer);
        ScriptTools.exportContract(outputName, "ORACLE_OPERATOR", oracleOperator);
        ScriptTools.exportContract(outputName, "RELAYER_OPERATOR", relayerOperator);
        ScriptTools.exportContract(outputName, "FACTORY", factory);
        ScriptTools.exportContract(outputName, "USER_CONFIG", uc);
        ScriptTools.exportContract(outputName, "CHANNEL", channel);
        ScriptTools.exportContract(outputName, "ENDPOINT", endpoint);
        ScriptTools.exportContract(outputName, "ORACLE", oracle);
        ScriptTools.exportContract(outputName, "RELAYER", relayer);
    }

    function _deploy(bytes memory initCode) public returns (address payable) {
        bytes memory data = bytes.concat(salt, initCode);
        (, bytes memory addr) = SAFE_CREATE2.call(data);
        return payable(address(uint160(bytes20(addr))));
    }

    /// @notice Deploy the Factory
    function deployFactory() public broadcast returns (address) {
        bytes memory byteCode = type(Factory).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer, salt));
        address factory = _deploy(initCode);
        require(Factory(factory).DEPLOYER() == deployer, "!deployer");
        save("Factory", factory);
        console.log("Factory    deployed at %s", factory);
        return factory;
    }

    /// @notice Deploy protocol contract
    function deployProtocol(address factory) public broadcast returns (address uc, address channel, address endpoint) {
        (uc, channel, endpoint) = Factory(factory).deploy();
        save("UserConfig", uc);
        console.log("UserConfig deployed at %s", uc);

        save("Channel", channel);
        console.log("Channel    deployed at %s", channel);

        save("Endpoint", endpoint);
        console.log("Endpoint   deployed at %s", endpoint);
    }

    /// @notice Deploy the Oracle
    function deployOralce(address endpoint) public broadcast returns (address) {
        bytes memory byteCode = type(Oracle).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer, endpoint));
        address payable oracle = _deploy(initCode);

        require(Oracle(oracle).owner() == deployer);
        require(Oracle(oracle).ENDPOINT() == endpoint);
        save("Oralce", oracle);
        console.log("Oracle     deployed at %s", oracle);
        return oracle;
    }

    /// @notice Deploy the Relayer
    function deployRelayer(address endpoint, address channel) broadcast public returns (address) {
        bytes memory byteCode = type(Relayer).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer, endpoint, channel));
        address payable relayer = _deploy(initCode);

        require(Relayer(relayer).owner() == deployer);
        require(Relayer(relayer).ENDPOINT() == endpoint);
        require(Relayer(relayer).CHANNEL() == channel);
        save("Relayer", relayer);
        console.log("Relayer    deployed at %s", relayer);
        return relayer;
    }

    /// @notice Set the protocol config
    function setConfig(address uc, address oracle, address relayer) public broadcast {
        IUserConfig(uc).setDefaultConfig(oracle, relayer);
        Config memory cfg = IUserConfig(uc).defaultConfig();
        require(cfg.oracle == oracle, "!oracle");
        require(cfg.relayer == relayer, "!relayer");

        IOperator(oracle).setApproved(oracleOperator, true);
        require(IOperator(oracle).isApproved(oracleOperator), "!o-operator");
        IOperator(relayer).setApproved(relayerOperator, true);
        require(IOperator(relayer).isApproved(relayerOperator), "!r-operator");
    }

    /// @notice Modifier that wraps a function in broadcasting.
    modifier broadcast() {
        vm.startBroadcast();
        _;
        vm.stopBroadcast();
    }
}
