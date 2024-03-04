// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {Common} from "create3-deploy/script/Common.s.sol";
import {ScriptTools} from "create3-deploy/script/ScriptTools.sol";

interface III {
    function isApproved(address operator) external view returns (bool);
    function setApproved(address operator, bool approve) external;

    function setFee(uint256 chainId, uint256 fee_) external;
    function setDstPrice(uint256 chainId, uint128 dstPriceRatio, uint128 dstGasPriceInWei) external;
    function setDstConfig(uint256 chainId, uint64 baseGas, uint64 gasPerByte) external;

    function fee(uint256 toChainId, address ua) external view returns (uint256);
    function fee(uint256 toChainId, address ua, uint256 size, bytes calldata params) external view returns (uint256);
}

contract Fee is Common {
    using stdJson for string;
    using ScriptTools for string;

    string instanceId;
    string config;
    string deployedContracts;
    address dao;

    function name() public pure override returns (string memory) {
        return "Fee";
    }

    function setUp() public override {
        super.setUp();

        instanceId = vm.envOr("INSTANCE_ID", string("fee.c"));
        config = ScriptTools.readInput(instanceId);
        deployedContracts = ScriptTools.readOutput("deploy.a");
        dao = deployedContracts.readAddress(".DAO");
    }

    function run(uint256 chainId) public {
        // require(dao == msg.sender, "!dao");
        setOracleFee(chainId);
        // setRelayerFee(chainId);
    }

    function setOracleFee(uint256 chainId) public broadcast {
        string memory key = string.concat(".ORACLE", ".", vm.toString(chainId), ".fee");
        uint256 fee = config.readUint(key);
        address oracle = deployedContracts.readAddress(".ORACLE");

        bool approved = III(oracle).isApproved(dao);
        if (!approved) {
            III(oracle).setApproved(dao, true);
        }
        III(oracle).setFee(chainId, fee);
        require(III(oracle).fee(chainId, address(0)) == fee);
    }

    function setRelayerFee(uint256 chainId) public broadcast {
        string memory prefix = string.concat(".RELAYER", ".", vm.toString(chainId));
        uint128 dstPriceRatio = uint128(config.readUint(string.concat(prefix, ".dstPriceRatio")));
        uint128 dstGasPriceInWei = uint128(config.readUint(string.concat(prefix, ".dstGasPriceInWei")));
        uint64 baseGas = uint64(config.readUint(string.concat(prefix, ".baseGas")));
        uint64 gasPerByte = uint64(config.readUint(string.concat(prefix, ".gasPerByte")));

        address relayer = deployedContracts.readAddress(".RELAYER");
        bool approved = III(relayer).isApproved(dao);
        if (!approved) {
            III(relayer).setApproved(dao, true);
        }
        III(relayer).setDstPrice(chainId, dstPriceRatio, dstGasPriceInWei);
        III(relayer).setDstConfig(chainId, baseGas, gasPerByte);
    }
}
