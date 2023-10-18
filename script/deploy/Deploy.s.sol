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

    address immutable ORMP_ADDR = 0x0034607daf9c1dc6628f6e09E81bB232B6603A89;
    bytes32 immutable ORMP_SALT = 0x4a177511c10933b157108cb8d40e2cbeeccafdec51c3445d5e117ac1981285be;
    address immutable ORACLE_ADDR = 0x0002396F1D52323fcd1ae8079b38808F046882c3;
    bytes32 immutable ORACLE_SALT = 0x4988d5215faf6ade0dcd51066e709ccb81edc58914ea7a60b0afa1f3a01c71f3;
    address immutable RELAYER_ADDR = 0x007EED6207c9AF3715964Fb7f8B5f44E002a3498;
    bytes32 immutable RELAYER_SALT = 0xcd9f567f57f0c293ba969f9c702f7684bb9e758d3a6bb88da8c99e6f1e851e5d;

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

        III(ormp).changeSetter{gas: 200000}(dao);
        require(III(ormp).setter() == dao, "!dao");

        III(oracle).changeOwner(dao);
        require(III(oracle).owner() == dao, "!dao");

        III(relayer).changeOwner(dao);
        require(III(relayer).owner() == dao, "!dao");
    }
}
