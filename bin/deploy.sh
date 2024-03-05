#!/usr/bin/env bash

set -eo pipefail

# forge script script/deploy/Deploy.s.sol:Deploy --chain-id 1     --broadcast --verify --slow
# forge script script/deploy/Deploy.s.sol:Deploy --chain-id 44    --broadcast --verify --slow
# forge script script/deploy/Deploy.s.sol:Deploy --chain-id 46    --broadcast --verify --slow
# forge script script/deploy/Deploy.s.sol:Deploy --chain-id 137   --broadcast --verify
# forge script script/deploy/Deploy.s.sol:Deploy --chain-id 42161 --broadcast --verify --slow --legacy --skip-simulation
forge script script/deploy/Deploy.s.sol:Deploy --chain-id 81457   --broadcast --verify --legacy --with-gas-price 1060000

# forge script script/deploy/Deploy.s.sol:Deploy --chain-id 43       --broadcast --verify --skip-simulation
# forge script script/deploy/Deploy.s.sol:Deploy --chain-id 421614   --broadcast --verify --skip-simulation --slow
# forge script script/deploy/Deploy.s.sol:Deploy --chain-id 11155111 --broadcast --verify --skip-simulation
