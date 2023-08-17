// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {Test} from "forge-std/Test.sol";
import {console2 as console} from "forge-std/console2.sol";
import {stdJson} from "forge-std/StdJson.sol";

import {Chains} from "./Chains.sol";
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
///         Then add a call to that function inside of `run`.
contract Deploy is Script {
    using stdJson for string;
    using ScriptTools for string;
    using Chains for uint256;

    address immutable SAFE_CREATE2_ADDR = 0x914d7Fec6aaC8cd542e72Bca78B30650d45643d7;
    bytes32 immutable FACTORY_SALT = 0x512e2cdf0dd7b2ea1dbcf0128403198109d8b0e29dbb99664f0f9aee5725988e;
    address immutable FACTORY_ADDR = 0x0000008b08479Fc4D0F2635E53E75539375A9640;
    bytes32 immutable CONFIG_SALT = 0x6b49a38b80eeb2a49f9a84c06d16c2533e3734d1a7e1581bfcac4869e0ed3c0a;
    address immutable CONFIG_ADDR = 0x0000005B195D46cA63f103372E2B857d55930732;
    bytes32 immutable CHANNEL_SALT = 0xb0b60ae57d28d9ba898436f10494d620680d21d7db9ecd3e5d2ce5453b4001a4;
    address immutable CHANNEL_ADDR = 0x00000022eCd1AB2e62b6687e78De82412a90eF38;
    bytes32 immutable ENDPOINT_SALT = 0xce2ef6c9cdfd599ee842528d63fe572e6cf704b95a8244283dd0d1c161a0cdba;
    address immutable ENDPOINT_ADDR = 0x00000008F1f78B182F9F14F6923A62ea55AA3215;
    bytes32 immutable ORACLE_SALT = 0x5ccdfdc815f09210c8e1f6bdfb33a09feae093fced0b9406a6f76b8245d1a722;
    address immutable ORACLE_ADDR = 0x0000006144281D235e8767681F422aF50B03ea6d;
    bytes32 immutable RELAYER_SALT = 0x938bae70de45a466391f47dfcddb39cfa4e443dc2c940e96d7ff2fc9abe00c8d;
    address immutable RELAYER_ADDR = 0x000000AE4cAfEd8fc43977374b39B157A9F383b8;

    string config;
    string instanceId;
    string outputName;
    address deployer;
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
        oracleOperator = config.readAddress(".ORACLE_OPERATOR");
        relayerOperator = config.readAddress(".RELAYER_OPERATOR");

        console.log("Deploying from %s", name());
        console.log("Deployment context: %s", getDeploymentContext());
    }

    /// @notice Deploy all of the contracts
    function run() public {
        require(deployer == msg.sender, "!deployer");

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

    function _deploy(bytes32 salt, bytes memory initCode) public returns (address payable) {
        bytes memory data = bytes.concat(salt, initCode);
        (, bytes memory addr) = SAFE_CREATE2_ADDR.call(data);
        return payable(address(uint160(bytes20(addr))));
    }

    /// @notice Deploy the Factory
    function deployFactory() public broadcast returns (address) {
        bytes memory byteCode = type(Factory).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer));
        address factory = _deploy(FACTORY_SALT, initCode);
        require(factory == FACTORY_ADDR, "!factory");
        require(Factory(factory).DEPLOYER() == deployer, "!deployer");
        console.log("Factory    deployed at %s", factory);
        return factory;
    }

    /// @notice Deploy protocol contract
    function deployProtocol(address factory) public broadcast returns (address uc, address channel, address endpoint) {
        (uc, channel, endpoint) = Factory(factory).deploy(CONFIG_SALT, CHANNEL_SALT, ENDPOINT_SALT);
        require(uc == CONFIG_ADDR, "!config");
        require(channel == CHANNEL_ADDR, "!chanel");
        require(endpoint == ENDPOINT_ADDR, "!endpoint");

        console.log("UserConfig deployed at %s", uc);
        console.log("Channel    deployed at %s", channel);
        console.log("Endpoint   deployed at %s", endpoint);
    }

    /// @notice Deploy the Oracle
    function deployOralce(address endpoint) public broadcast returns (address) {
        bytes memory byteCode = type(Oracle).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer, endpoint));
        address payable oracle = _deploy(ORACLE_SALT, initCode);
        require(oracle == ORACLE_ADDR, "!oracle");

        require(Oracle(oracle).owner() == deployer);
        require(Oracle(oracle).ENDPOINT() == endpoint);
        console.log("Oracle     deployed at %s", oracle);
        return oracle;
    }

    /// @notice Deploy the Relayer
    function deployRelayer(address endpoint, address channel) public broadcast returns (address) {
        bytes memory byteCode = type(Relayer).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer, endpoint, channel));
        address payable relayer = _deploy(RELAYER_SALT, initCode);
        require(relayer == RELAYER_ADDR, "!relayer");

        require(Relayer(relayer).owner() == deployer);
        require(Relayer(relayer).ENDPOINT() == endpoint);
        require(Relayer(relayer).CHANNEL() == channel);
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
