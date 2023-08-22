// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";

import "../Common.s.sol";

import "../../src/ORMP.sol";
import {Relayer} from "../../src/eco/Relayer.sol";
import {Oracle} from "../../src/eco/Oracle.sol";

interface III {
    function PROTOCOL() external view returns (address);
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
contract Deploy is Common {
    using stdJson for string;
    using ScriptTools for string;

    address immutable ORMP_ADDR = 0x00000000fec9f746a2138D9C6f42794236f3aca8;
    bytes32 immutable ORMP_SALT = 0x7380f497506e3882cfa3c434e0248d56c459927f453ad4fca7c4d3ae7f79992f;
    address immutable ORACLE_ADDR = 0x00000012f877F68a8D2410b683FDC8214f4b5194;
    bytes32 immutable ORACLE_SALT = 0x28a8dc03b07b43b2b00a5ce326d8b1a2f763383799fdccab482196a6a67c206a;
    address immutable RELAYER_ADDR = 0x000000fbfBc6954C8CBba3130b5Aee7f3Ea5108e;
    bytes32 immutable RELAYER_SALT = 0xca2e642f6df8329eb191014b3e8bcea3ac247a1d17a2007aee1c019f58a07178;

    string config;
    string instanceId;
    string outputName;
    address deployer;
    address dao;
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
        config = ScriptTools.readInput(instanceId);

        deployer = config.readAddress(".DEPLOYER");
        dao = config.readAddress(".DAO");
        oracleOperator = config.readAddress(".ORACLE_OPERATOR");
        relayerOperator = config.readAddress(".RELAYER_OPERATOR");
    }

    /// @notice Deploy all of the contracts
    function run() public {
        require(deployer == msg.sender, "!deployer");

        address ormp = deployProtocol();

        address oracle = deployOralce(ormp);
        address relayer = deployRelayer(ormp);

        setConfig(ormp, oracle, relayer);

        ScriptTools.exportContract(outputName, "DAO", dao);
        ScriptTools.exportContract(outputName, "ormp", ormp);
        ScriptTools.exportContract(outputName, "ORACLE", oracle);
        ScriptTools.exportContract(outputName, "RELAYER", relayer);
    }

    /// @notice Deploy the protocol
    function deployProtocol() public broadcast returns (address) {
        bytes memory byteCode = type(ORMP).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer));
        address ormp = _deploy(ORMP_SALT, initCode);
        require(ormp == ORMP_ADDR, "!ormp");
        require(III(ormp).setter() == deployer, "!deployer");
        console.log("ormp   deployed at %s", ormp);
        return ormp;
    }

    /// @notice Deploy the Oracle
    function deployOralce(address ormp) public broadcast returns (address) {
        bytes memory byteCode = type(Oracle).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer, ormp));
        address oracle = _deploy(ORACLE_SALT, initCode);
        require(oracle == ORACLE_ADDR, "!oracle");

        require(III(oracle).owner() == deployer);
        require(III(oracle).PROTOCOL() == ormp);
        console.log("Oracle     deployed at %s", oracle);
        return oracle;
    }

    /// @notice Deploy the Relayer
    function deployRelayer(address ormp) public broadcast returns (address) {
        bytes memory byteCode = type(Relayer).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer, ormp));
        address relayer = _deploy(RELAYER_SALT, initCode);
        require(relayer == RELAYER_ADDR, "!relayer");

        require(III(relayer).owner() == deployer);
        require(III(relayer).PROTOCOL() == ormp);
        console.log("Relayer    deployed at %s", relayer);
        return relayer;
    }

    /// @notice Set the protocol config
    function setConfig(address ormp, address oracle, address relayer) public broadcast {
        ORMP(ormp).setDefaultConfig(oracle, relayer);
        Config memory cfg = ORMP(ormp).getDefaultConfig();
        require(cfg.oracle == oracle, "!oracle");
        require(cfg.relayer == relayer, "!relayer");

        III(oracle).setApproved(oracleOperator, true);
        require(III(oracle).isApproved(oracleOperator), "!o-operator");
        III(relayer).setApproved(relayerOperator, true);
        require(III(relayer).isApproved(relayerOperator), "!r-operator");

        III(ormp).changeSetter(dao);
        require(III(ormp).setter() == dao, "!dao");

        III(oracle).changeOwner(dao);
        require(III(oracle).owner() == dao, "!dao");

        III(relayer).changeOwner(dao);
        require(III(relayer).owner() == dao, "!dao");
    }
}
