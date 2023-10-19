#! /usr/bin/env bash

set -eo pipefail

deployer=0x0f14341A7f464320319025540E8Fe48Ad0fe5aec
ormp=0x0034607daf9c1dc6628f6e09E81bB232B6603A89
oracle=0x0002396F1D52323fcd1ae8079b38808F046882c3
relayer=0x007EED6207c9AF3715964Fb7f8B5f44E002a3498

verify() {
  local addr; addr=$1
  local chain_id; chain_id=$2
  local args; args=$3
  local path; path=$4
  local name; name=${path#*:}
  (set -x; forge verify-contract \
    --chain-id $chain_id \
    --num-of-optimizations 999999 \
    --watch \
    --constructor-args $args \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --compiler-version v0.8.17+commit.8df45f5f \
    --show-standard-json-input \
    $addr \
    $path > script/output/$chain_id/$name.v.json)
}

verify $ormp    421614 $(cast abi-encode "constructor(address)" $deployer)               src/ORMP.sol:ORMP
verify $ormp    44     $(cast abi-encode "constructor(address)" $deployer)               src/ORMP.sol:ORMP

verify $oracle  421614 $(cast abi-encode "constructor(address,address)" $deployer $ormp) src/eco/Oracle.sol:Oracle
verify $oracle  44     $(cast abi-encode "constructor(address,address)" $deployer $ormp) src/eco/Oracle.sol:Oracle

verify $relayer 421614 $(cast abi-encode "constructor(address,address)" $deployer $ormp) src/eco/Relayer.sol:Relayer
verify $relayer 44     $(cast abi-encode "constructor(address,address)" $deployer $ormp) src/eco/Relayer.sol:Relayer
