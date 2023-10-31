// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {console2 as console} from "forge-std/console2.sol";
import {Common} from "create3-deploy/script/Common.s.sol";
import {ScriptTools} from "create3-deploy/script/ScriptTools.sol";

import {Config, ORMP} from "../../src/ORMP.sol";
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

    address immutable ORMP_ADDR = 0x009D223Aad560e72282db9c0438Ef1ef2bf7703D;
    bytes32 immutable ORMP_SALT = 0x0a68f3af806b448a1e6e4b5b2fced6f144cff5e1bfd733bcb51916a6d696e7aa;

    address immutable ORACLE_ADDR = 0x00BD655DDfA7aFeF4BB109FE1F938724527B49D8;
    bytes32 immutable ORACLE_SALT = 0xfbb782802ad938a1df1c89407273c248c1d7af7b4f9e94704564a4ca792a4296;

    address immutable RELAYER_ADDR = 0x0065a081a11cc1f6e1692c2A08E9AF36b17973eC;
    bytes32 immutable RELAYER_SALT = 0x5f1532f1a200d9076629b2691489b82712c30ba913251eae5871243a0faa5062;

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

        // deployProtocol();
        // deployOralce();
        // deployRelayer();

        setConfig();

        // ScriptTools.exportContract(outputName, "DAO", dao);
        // ScriptTools.exportContract(outputName, "ORMP", ORMP_ADDR);
        // ScriptTools.exportContract(outputName, "ORACLE", ORMP_ADDR);
        // ScriptTools.exportContract(outputName, "RELAYER", RELAYER_ADDR);
    }

    /// @notice Deploy the protocol
    function deployProtocol() public broadcast returns (address) {
        bytes memory byteCode = type(ORMP).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer));
        address ormp = _deploy3(ORMP_SALT, initCode);
        require(ormp == ORMP_ADDR, "!ormp");
        require(III(ormp).setter() == deployer, "!deployer");
        console.log("ORMP    deployed at: %s", ormp);
        return ormp;
    }

    /// @notice Deploy the Oracle
    function deployOralce() public broadcast returns (address) {
        bytes memory byteCode = type(Oracle).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer, ORMP_ADDR));
        address oracle = _deploy3(ORACLE_SALT, initCode);
        require(oracle == ORACLE_ADDR, "!oracle");

        require(III(oracle).owner() == deployer);
        require(III(oracle).PROTOCOL() == ORMP_ADDR);
        console.log("Oracle  deployed at: %s", oracle);
        return oracle;
    }

    /// @notice Deploy the Relayer
    function deployRelayer() public broadcast returns (address) {
        bytes memory byteCode = type(Relayer).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer, ORMP_ADDR));
        address relayer = _deploy3(RELAYER_SALT, initCode);
        require(relayer == RELAYER_ADDR, "!relayer");

        require(III(relayer).owner() == deployer);
        require(III(relayer).PROTOCOL() == ORMP_ADDR);
        console.log("Relayer deployed at: %s", relayer);
        return relayer;
    }

    /// @notice Set the protocol config
    function setConfig() public broadcast {
        ORMP(ORMP_ADDR).setDefaultConfig(ORACLE_ADDR, RELAYER_ADDR);
        Config memory cfg = ORMP(ORMP_ADDR).getDefaultConfig();
        require(cfg.oracle == ORACLE_ADDR, "!oracle");
        require(cfg.relayer == RELAYER_ADDR, "!relayer");

        III(ORACLE_ADDR).setApproved(oracleOperator, true);
        require(III(ORACLE_ADDR).isApproved(oracleOperator), "!o-operator");
        III(RELAYER_ADDR).setApproved(relayerOperator, true);
        require(III(RELAYER_ADDR).isApproved(relayerOperator), "!r-operator");

        III(ORMP_ADDR).changeSetter(dao);
        require(III(ORMP_ADDR).setter() == dao, "!dao");

        III(ORACLE_ADDR).changeOwner(dao);
        require(III(ORACLE_ADDR).owner() == dao, "!dao");

        III(RELAYER_ADDR).changeOwner(dao);
        require(III(RELAYER_ADDR).owner() == dao, "!dao");
    }
}
