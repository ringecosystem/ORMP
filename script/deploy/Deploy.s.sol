// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Script } from "forge-std/Script.sol";
import { Test } from "forge-std/Test.sol";
import { console2 as console } from "forge-std/console2.sol";
import { stdJson } from "forge-std/StdJson.sol";

import { Deployer } from "./Deployer.sol";

import { Channel } from "../../src/Channel.sol";
import { Endpoint } from "../../src/Endpoint.sol";
import { UserConfig } from "../../src/UserConfig.sol";
import { Relayer } from "../../src/eco/Relayer.sol";
import { Oracle } from "../../src/eco/Oracle.sol";

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
        address deployer = msg.sender;
        uint256 nonce = vm.getNonce(deployer);
        address preuc = getContractAddress(deployer, nonce);
        address posuc = deployUserConfig();
        require(preuc == posuc, "!uc");
        address precn = getContractAddress(deployer, nonce + 1);
        address preep = getContractAddress(deployer, nonce + 2);
        address poscn = deployChannel(preuc, preep);
        address posep = deployEndpoint(preuc, precn);
        require(poscn == precn, "!cn");
        require(posep == preep, "!ep");

        deployOralce(preep);
        deployRelayer(preep, precn);
    }

    /// @notice Deploy the UserConfig
    function deployUserConfig() broadcast public returns (address) {
        UserConfig uc = new UserConfig();
        require(uc.setter() == msg.sender);
        save("UserConfig", address(uc));
        console.log("UserConfig deployed at %s", address(uc));
        return address(uc);
    }

    /// @notice Deploy the Channel
    function deployChannel(address uc, address ep) broadcast public returns (address) {
        Channel cn = new Channel(uc, ep);
        require(cn.CONFIG() == uc);
        require(cn.ENDPOINT() == ep);
        save("Channel", address(cn));
        console.log("Channel    deployed at %s", address(cn));
        return address(cn);
    }

    /// @notice Deploy the Endpoint
    function deployEndpoint(address uc, address cn) broadcast public returns (address) {
        Endpoint ep = new Endpoint(uc, cn);
        require(ep.CONFIG() == uc);
        require(ep.CHANNEL() == cn);
        save("Enpoint", address(ep));
        console.log("Endpoint   deployed at %s", address(ep));
        return address(ep);
    }

    /// @notice Deploy the Oracle
    function deployOralce(address enpoint) broadcast public returns (address) {
        Oracle oracle = new Oracle(enpoint);
        require(oracle.owner() == msg.sender);
        require(oracle.ENDPOINT() == enpoint);
        save("Oralce", address(oracle));
        console.log("Oracle     deployed at %s", address(oracle));
        return address(oracle);
    }

    /// @notice Deploy the Relayer
    function deployRelayer(address enpoint, address channel) broadcast public returns (address) {
        Relayer relayer = new Relayer(enpoint, channel);
        require(relayer.owner() == msg.sender);
        require(relayer.ENDPOINT() == enpoint);
        require(relayer.CHANNEL() == channel);
        save("Relayer", address(relayer));
        console.log("Relayer    deployed at %s", address(relayer));
        return address(relayer);
    }

    /// @notice Modifier that wraps a function in broadcasting.
    modifier broadcast() {
        vm.startBroadcast();
        _;
        vm.stopBroadcast();
    }
}
