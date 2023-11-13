#!/usr/bin/env bash

set -eo pipefail

c3=$PWD/script/input/c3.json

deployer=$(jq -r ".DEPLOYER" $c3)
dao=$(jq -r ".MSGDAO" $c3)
ormp=$(jq -r ".ORMP_ADDR" $c3)
oracle=$(jq -r ".ORACLE_ADDR" $c3)
relayer=$(jq -r ".RELAYER_ADDR" $c3)

seth send -F $deployer $ormp "changeSetter(address)" $dao --chain darwinia
seth send -F $deployer $ormp "changeSetter(address)" $dao --chain arbitrum

seth send -F $deployer $oracle "changeOwner(address)" $dao --chain darwinia
seth send -F $deployer $oracle "changeOwner(address)" $dao --chain arbitrum

seth send -F $deployer $relayer "changeOwner(address)" $dao --chain darwinia
seth send -F $deployer $relayer "changeOwner(address)" $dao --chain arbitrum
