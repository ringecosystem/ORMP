#! /usr/bin/env bash

set -eo pipefail

set -x
# forge script script/config/Oracle.s.sol:Oracle --sig "run(uint256)" 42161 --chain-id 46    --broadcast --slow
# forge script script/config/Oracle.s.sol:Oracle --sig "run(uint256)" 46    --chain-id 42161 --broadcast --slow --legacy

forge script script/config/Oracle.s.sol:Oracle --sig "run(uint256)" 11155111 --chain-id 44    --broadcast
