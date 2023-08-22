#! /usr/bin/env bash

set -eo pipefail

set -x

local_chain_id=${1:?}
remote_chain_id=${2:?}

forge script script/fee/Fee.s.sol:Fee --sig "run(uint256)" $remote_chain_id --chain-id $local_chain_id --broadcast
