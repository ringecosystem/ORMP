// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {Common} from "create3-deploy/script/Common.s.sol";
import {ScriptTools} from "create3-deploy/script/ScriptTools.sol";

interface III {
    function isApproved(address operator) external view returns (bool);
    function setApproved(address operator, bool approve) external;
    function setDapi(uint256 chainId, address dapi) external;
    function dapiOf(uint256 chainId) external view returns (address);
}

contract Oracle is Common {
    using stdJson for string;
    using ScriptTools for string;

    string instanceId;
    string config;
    string deployedContracts;
    address dao;

    function name() public pure override returns (string memory) {
        return "Oracle dAPI Config";
    }

    function setUp() public override {
        super.setUp();

        instanceId = vm.envOr("INSTANCE_ID", string("oracle.c"));
        config = ScriptTools.readInput(instanceId);
        deployedContracts = ScriptTools.readOutput("deploy.a");
        dao = deployedContracts.readAddress(".DAO");
    }

    function run(uint256 chainId) public {
        require(dao == msg.sender, "!dao");
        setDapi(chainId);
    }

    function setDapi(uint256 chainId) public broadcast {
        string memory key = string.concat(".", vm.toString(chainId));
        address dAPI = config.readAddress(key);
        address oracle = deployedContracts.readAddress(".ORACLE");

        bool approved = III(oracle).isApproved(dao);
        if (!approved) {
            III(oracle).setApproved(dao, true);
        }
        III(oracle).setDapi(chainId, dAPI);
        require(III(oracle).dapiOf(chainId) == dAPI);
    }
}
