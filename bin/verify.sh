#! /usr/bin/env bash

set -eo pipefail

set -x

deployer=0x0f14341A7f464320319025540E8Fe48Ad0fe5aec
ormp=0x0034607daf9c1dc6628f6e09E81bB232B6603A89

forge verify-contract \
  --chain-id 421614 \
  --num-of-optimizations 999999 \
  --watch \
  --constructor-args $(cast abi-encode "constructor(address)" $deployer) \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --compiler-version v0.8.17+commit.8df45f5f \
  --verifier etherscan \
  --verifier-url https://api-goerli.arbiscan.io/api \
  --show-standard-json-input \
  0x0034607daf9c1dc6628f6e09E81bB232B6603A89 \
  src/ORMP.sol:ORMP > script/output/421614/ORMP.v.json

forge verify-contract \
  --chain-id 421614 \
  --num-of-optimizations 999999 \
  --watch \
  --constructor-args $(cast abi-encode "constructor(address,address)" $deployer $ormp) \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --compiler-version v0.8.17+commit.8df45f5f \
  --verifier etherscan \
  --verifier-url https://api-goerli.arbiscan.io/api \
  --show-standard-json-input \
  0x0002396F1D52323fcd1ae8079b38808F046882c3 \
  src/eco/Oracle.sol:Oracle > script/output/421614/Oracle.v.json

forge verify-contract \
  --chain-id 421614 \
  --num-of-optimizations 999999 \
  --watch \
  --constructor-args $(cast abi-encode "constructor(address,address)" $deployer $ormp) \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --compiler-version v0.8.17+commit.8df45f5f \
  --verifier etherscan \
  --verifier-url https://api-goerli.arbiscan.io/api \
  --show-standard-json-input \
  0x007EED6207c9AF3715964Fb7f8B5f44E002a3498 \
  src/eco/Relayer.sol:Relayer > script/output/421614/Relayer.v.json


forge verify-contract \
  --chain-id 44 \
  --num-of-optimizations 999999 \
  --watch \
  --constructor-args $(cast abi-encode "constructor(address)" $deployer) \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --compiler-version v0.8.17+commit.8df45f5f \
  --verifier etherscan \
  --verifier-url https://crab.api.subscan.io/api/scan/evm/contract/verifysource \
  --show-standard-json-input \
  0x0034607daf9c1dc6628f6e09E81bB232B6603A89 \
  src/ORMP.sol:ORMP > script/output/44/ORMP.v.json

forge verify-contract \
  --chain-id 44 \
  --num-of-optimizations 999999 \
  --watch \
  --constructor-args $(cast abi-encode "constructor(address,address)" $deployer $ormp) \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --compiler-version v0.8.17+commit.8df45f5f \
  --verifier etherscan \
  --verifier-url https://crab.api.subscan.io/api/scan/evm/contract/verifysource \
  --show-standard-json-input \
  0x0002396F1D52323fcd1ae8079b38808F046882c3 \
  src/eco/Oracle.sol:Oracle > script/output/44/Oracle.v.json

forge verify-contract \
  --chain-id 44 \
  --num-of-optimizations 999999 \
  --watch \
  --constructor-args $(cast abi-encode "constructor(address,address)" $deployer $ormp) \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --compiler-version v0.8.17+commit.8df45f5f \
  --verifier etherscan \
  --verifier-url https://crab.api.subscan.io/api/scan/evm/contract/verifysource \
  --show-standard-json-input \
  0x007EED6207c9AF3715964Fb7f8B5f44E002a3498 \
  src/eco/Relayer.sol:Relayer > script/output/44/Relayer.v.json

