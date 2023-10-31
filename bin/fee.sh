#! /usr/bin/env bash

set -eo pipefail

set -x
forge script script/fee/Fee.s.sol:Fee --sig "run(uint256)" 421614 --chain-id 44     --broadcast
forge script script/fee/Fee.s.sol:Fee --sig "run(uint256)" 44     --chain-id 421614 --broadcast # --skip-simulation
