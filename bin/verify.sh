#! /usr/bin/env bash

set -eo pipefail

set -x

deployer=0x0f14341A7f464320319025540E8Fe48Ad0fe5aec
ormp=0x0034607daf9c1dc6628f6e09E81bB232B6603A89
forge verify-contract \
  --chain-id 44 \
  --num-of-optimizations 999999 \
  --watch \
  --constructor-args $(cast abi-encode "constructor(address)" $deployer) \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --compiler-version v0.8.17+commit.8df45f5f \
  0x0034607daf9c1dc6628f6e09E81bB232B6603A89 \
  src/ORMP.sol:ORMP

