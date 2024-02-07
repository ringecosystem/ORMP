#!/usr/bin/env bash

set -eo pipefail

c3=$PWD/script/input/c3.json

deployer=$(jq -r ".DEPLOYER" $c3)
ormp=$(jq -r ".ORMP_ADDR" $c3)
oracle=$(jq -r ".ORMPORACLE_ADDR" $c3)
relayer=$(jq -r ".RELAYER_ADDR" $c3)

set -x

seth send -F $deployer $ormp "setDefaultConfig(address,address)" $oracle $relayer --chain crab
# seth send -F $deployer $ormp "setDefaultConfig(address,address)" $oracle $relayer --chain sepolia
# seth send -F $deployer $ormp "setDefaultConfig(address,address)" $oracle $relayer --chain arbitrum-sepolia
