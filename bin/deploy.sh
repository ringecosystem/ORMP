#!/usr/bin/env bash

set -eo pipefail

forge script script/deploy/Deploy.s.sol:Deploy --chain-id 44     --broadcast --verify
forge script script/deploy/Deploy.s.sol:Deploy --chain-id 421614 --broadcast --verify --skip-simulation
