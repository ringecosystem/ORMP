// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Script } from "forge-std/Script.sol";
import { Test } from "forge-std/Test.sol";
import { console2 as console } from "forge-std/console2.sol";
import { stdJson } from "forge-std/StdJson.sol";

import { Deployer } from "./Deployer.sol";

import { UserConfig } from "../../src/UserConfig.sol";

/// @title Deploy
/// @notice Script used to deploy a ORMP protocol. The entire protocol is deployed within the `run` function.
///         To add a new contract to the protocol, add a public function that deploys that individual contract.
///         Then add a call to that function inside of `run`. Be sure to call the `save` function after each
///         deployment so that `hardhat-deploy` style artifacts can be generated using a call to `sync()`.
contract Deploy is Deployer {
    /// @notice The name of the script, used to ensure the right deploy artifacts
    ///         are used.
    function name() public pure override returns (string memory) {
        return "Deploy";
    }

    function setUp() public override {
        super.setUp();

        console.log("Deploying from %s", deployScript);
        console.log("Deployment context: %s", deploymentContext);
    }

    /// @notice Deploy all of the contracts
    function run() public {
        deployUserConfig();
    }

    /// @notice Deploy the UserConfig
    function deployUserConfig() broadcast public returns (address) {
        UserConfig uc = new UserConfig();
        require(uc.setter() == msg.sender);
        save("UserConfig", address(uc));
        console.log("UserConfig deployed at %s", address(uc));
        return address(uc);
    }

    /// @notice Modifier that wraps a function in broadcasting.
    modifier broadcast() {
        vm.startBroadcast();
        _;
        vm.stopBroadcast();
    }
}
