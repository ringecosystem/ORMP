.PHONY: add clean test bench deploy
.PHONY: doc salt tools foundry

-include .env

all    :; forge build
clean  :; forge clean
test   :; forge test --nmc Benchmark
bench  :; forge test --mc Benchmark
deploy :; forge script script/deploy/Deploy.s.sol:Deploy --chain-id ${chain-id} --broadcast --verify

tools  :; foundry
foundry:; curl -L https://foundry.paradigm.xyz | bash

doc    :; @bash ./bin/doc.sh
salt   :; @bash ./bin/salt.sh
fee    :; @bash ./bin/fee.sh ${local} ${remote}
config :; @bash ./bin/config.sh ${local} ${remote}
