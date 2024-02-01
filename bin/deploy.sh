#!/usr/bin/env bash

set -eo pipefail

# forge script script/deploy/Deploy.s.sol:Deploy --chain-id 1     --broadcast --verify --slow --legacy
# forge script script/deploy/Deploy.s.sol:Deploy --chain-id 46    --broadcast --verify --slow
# forge script script/deploy/Deploy.s.sol:Deploy --chain-id 42161 --broadcast --verify --slow --legacy

forge script script/deploy/Deploy.s.sol:Deploy --chain-id 43       --broadcast --verify --skip-simulation --slow
# forge script script/deploy/Deploy.s.sol:Deploy --chain-id 44       --broadcast --verify --skip-simulation --slow
# forge script script/deploy/Deploy.s.sol:Deploy --chain-id 421614   --broadcast --verify --skip-simulation --slow
# forge script script/deploy/Deploy.s.sol:Deploy --chain-id 11155111 --broadcast --verify --skip-simulation --slow
