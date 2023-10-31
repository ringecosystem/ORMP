#! /usr/bin/env bash

set -eo pipefail

deployer=0x0f14341A7f464320319025540E8Fe48Ad0fe5aec
ormp=0x009D223Aad560e72282db9c0438Ef1ef2bf7703D
oracle=0x00BD655DDfA7aFeF4BB109FE1F938724527B49D8
relayer=0x0065a081a11cc1f6e1692c2A08E9AF36b17973eC

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
