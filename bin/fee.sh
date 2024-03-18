#! /usr/bin/env bash

set -eo pipefail

set -x
# forge script script/fee/Fee.s.sol:Fee --sig "run(uint256)" 46    --chain-id 1     --broadcast --slow 
forge script script/fee/Fee.s.sol:Fee --sig "run(uint256)" 42161 --chain-id 1     --broadcast --slow 
# forge script script/fee/Fee.s.sol:Fee --sig "run(uint256)" 1     --chain-id 46    --broadcast --slow
forge script script/fee/Fee.s.sol:Fee --sig "run(uint256)" 42161 --chain-id 46    --broadcast --slow
# forge script script/fee/Fee.s.sol:Fee --sig "run(uint256)" 44    --chain-id 46    --broadcast --slow --legacy
# forge script script/fee/Fee.s.sol:Fee --sig "run(uint256)" 46    --chain-id 42161 --broadcast --slow --legacy --skip-simulation
# forge script script/fee/Fee.s.sol:Fee --sig "run(uint256)" 1     --chain-id 42161 --broadcast --slow --legacy --skip-simulation
# forge script script/fee/Fee.s.sol:Fee --sig "run(uint256)" 46    --chain-id 44    --broadcast --slow --legacy
# forge script script/fee/Fee.s.sol:Fee --sig "run(uint256)" 46    --chain-id 137   --broadcast
# forge script script/fee/Fee.s.sol:Fee --sig "run(uint256)" 137   --chain-id 46    --broadcast --slow --legacy
forge script script/fee/Fee.s.sol:Fee --sig "run(uint256)" 81457   --chain-id 42161 --broadcast --legacy --skip-simulation
forge script script/fee/Fee.s.sol:Fee --sig "run(uint256)" 42161   --chain-id 81457 --broadcast --legacy --with-gas-price 1060000

# forge script script/fee/Fee.s.sol:Fee --sig "run(uint256)" 11155111 --chain-id 43       --broadcast
# forge script script/fee/Fee.s.sol:Fee --sig "run(uint256)" 421614   --chain-id 43       --broadcast
# forge script script/fee/Fee.s.sol:Fee --sig "run(uint256)" 43       --chain-id 11155111 --broadcast
# forge script script/fee/Fee.s.sol:Fee --sig "run(uint256)" 421614   --chain-id 11155111 --broadcast
# forge script script/fee/Fee.s.sol:Fee --sig "run(uint256)" 43       --chain-id 421614   --broadcast --skip-simulation --legacy --slow
# forge script script/fee/Fee.s.sol:Fee --sig "run(uint256)" 11155111 --chain-id 421614   --broadcast --skip-simulation --legacy --slow
