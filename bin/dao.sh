#!/usr/bin/env bash

set -eo pipefail

c3=$PWD/script/input/c3.json

deployer=$(jq -r ".DEPLOYER" $c3)
dao=$(jq -r ".MSGDAO" $c3)
subapi_dao=$(jq -r ".SUBAPIDAO_ADDR" $c3)
ormp=$(jq -r ".ORMP_ADDR" $c3)
oracle=$(jq -r ".ORACLEV2_ADDR" $c3)
relayer=$(jq -r ".RELAYER_ADDR" $c3)

set -x

# seth send -F $deployer $ormp "changeSetter(address)" $dao --chain darwinia
# seth send -F $deployer $ormp "changeSetter(address)" $dao --chain arbitrum
# seth send -F $deployer $ormp "changeSetter(address)" $dao --chain ethereum

# seth send -F $deployer $oracle "changeOwner(address)" $dao --chain darwinia
# seth send -F $deployer $oracle "changeOwner(address)" $dao --chain arbitrum
# seth send -F $deployer $oracle "changeOwner(address)" $dao --chain ethereum

# seth send -F $deployer $relayer "changeOwner(address)" $dao --chain darwinia
# seth send -F $deployer $relayer "changeOwner(address)" $dao --chain arbitrum
# seth send -F $deployer $relayer "changeOwner(address)" $dao --chain ethereum

seth send -F $deployer $oracle "changeOwner(address)" $subapi_dao --chain crab
seth send -F $deployer $oracle "changeOwner(address)" $subapi_dao --chain sepolia
