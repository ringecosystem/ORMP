#! /usr/bin/env bash

set -eo pipefail

c3=$PWD/script/input/c3.json

deployer=$(jq -r ".DEPLOYER" $c3)
ormp=$(jq -r ".ORMP_ADDR" $c3)
oracle=$(jq -r ".ORACLE_ADDR" $c3)
relayer=$(jq -r ".RELAYER_ADDR" $c3)
subapi=$(jq -r ".SUBAPI_ADDR" $c3)

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

# verify $ormp    42161 $(cast abi-encode "constructor(address)" $deployer)               src/ORMP.sol:ORMP
# verify $ormp    46    $(cast abi-encode "constructor(address)" $deployer)               src/ORMP.sol:ORMP
# verify $oracle  42161 $(cast abi-encode "constructor(address,address)" $deployer $ormp) src/eco/Oracle.sol:Oracle
# verify $oracle  46    $(cast abi-encode "constructor(address,address)" $deployer $ormp) src/eco/Oracle.sol:Oracle
# verify $relayer 42161 $(cast abi-encode "constructor(address,address)" $deployer $ormp) src/eco/Relayer.sol:Relayer
# verify $relayer 46    $(cast abi-encode "constructor(address,address)" $deployer $ormp) src/eco/Relayer.sol:Relayer

verify $oracle  44    $(cast abi-encode "constructor(address,address,address)" $deployer $ormp $subapi) src/eco/Oracle.sol:Oracle
verify $oracle  421614    $(cast abi-encode "constructor(address,address,address)" $deployer $ormp $subapi) src/eco/Oracle.sol:Oracle
