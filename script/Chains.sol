// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Vm} from "forge-std/Vm.sol";

/// @notice Chain IDs for the various networks.
library Chains {
    uint256 internal constant Ethereum = 1;
    uint256 internal constant Goerli = 5;
    uint256 internal constant Optimism = 10;
    uint256 internal constant Pangolin = 43;
    uint256 internal constant Crab = 44;
    uint256 internal constant Pangoro = 45;
    uint256 internal constant Darwinia = 46;
    uint256 internal constant OptimismGoerli = 420;
    uint256 internal constant Arbitrum = 42161;
    uint256 internal constant ArbitrumGoerli = 421613;
    uint256 internal constant ArbitrumSepolia = 421614;
    uint256 internal constant Sepolia = 11155111;
    uint256 internal constant OptimismSepolia = 11155420;
    Vm constant vm = Vm(address(bytes20(uint160(uint256(keccak256("hevm cheat code"))))));

    function toChainName(uint256 chainid) internal pure returns (string memory) {
        if (chainid == Ethereum) {
            return "ethereum";
        } else if (chainid == Goerli) {
            return "goerli";
        } else if (chainid == Optimism) {
            return "optimism";
        } else if (chainid == Pangolin) {
            return "pangolin";
        } else if (chainid == Crab) {
            return "crab";
        } else if (chainid == Pangoro) {
            return "pangoro";
        } else if (chainid == Darwinia) {
            return "darwinia";
        } else if (chainid == OptimismGoerli) {
            return "optimism-goerli";
        } else if (chainid == Arbitrum) {
            return "arbitrum";
        } else if (chainid == ArbitrumGoerli) {
            return "arbitrum-goerli";
        } else if (chainid == ArbitrumSepolia) {
            return "arbitrum-sepolia";
        } else if (chainid == Sepolia) {
            return "sepolia";
        } else if (chainid == OptimismSepolia) {
            return "optimism-sepolia";
        } else {
            return vm.toString(chainid);
        }
    }
}
