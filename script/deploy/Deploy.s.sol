// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {console2 as console} from "forge-std/console2.sol";
import {Common} from "create3-deploy/script/Common.s.sol";
import {ScriptTools} from "create3-deploy/script/ScriptTools.sol";

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

        address ormp = deployProtocol();

        address oracle = deployOralce(ormp);
        address relayer = deployRelayer(ormp);

        setConfig(ormp, oracle, relayer);

        ScriptTools.exportContract(outputName, "DAO", dao);
        ScriptTools.exportContract(outputName, "ORMP", ormp);
        ScriptTools.exportContract(outputName, "ORACLE", oracle);
        ScriptTools.exportContract(outputName, "RELAYER", relayer);
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
    function deployOralce(address ormp) public broadcast returns (address) {
        bytes memory byteCode = type(Oracle).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer, ormp));
        address oracle = _deploy3(ORACLE_SALT, initCode);
        require(oracle == ORACLE_ADDR, "!oracle");

        require(III(oracle).owner() == deployer);
        require(III(oracle).PROTOCOL() == ormp);
        console.log("Oracle  deployed at: %s", oracle);
        return oracle;
    }

    /// @notice Deploy the Relayer
    function deployRelayer(address ormp) public broadcast returns (address) {
        bytes memory byteCode = type(Relayer).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer, ormp));
        address relayer = _deploy3(RELAYER_SALT, initCode);
        require(relayer == RELAYER_ADDR, "!relayer");

        require(III(relayer).owner() == deployer);
        require(III(relayer).PROTOCOL() == ormp);
        console.log("Relayer deployed at: %s", relayer);
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

        III(ormp).changeSetter{gas: 200000}(dao);
        require(III(ormp).setter() == dao, "!dao");

        III(oracle).changeOwner(dao);
        require(III(oracle).owner() == dao, "!dao");

        III(relayer).changeOwner(dao);
        require(III(relayer).owner() == dao, "!dao");
    }
}
