.PHONY: all clean test bench deploy fmt
.PHONY: doc salt tools foundry

-include .env

all    :; @forge build
clean  :; @forge clean
fmt    :; @forge fmt
test   :; @forge test --nmc Benchmark
bench  :; @forge test --mc Benchmark

tools  :  foundry
foundry:; curl -L https://foundry.paradigm.xyz | bash

doc    :; @bash ./bin/doc.sh
salt   :; @bash ./bin/salt.sh
deploy :; @bash ./bin/deploy.sh
fee    :; @bash ./bin/fee.sh ${local} ${remote}
config :; @bash ./bin/config.sh ${local} ${remote}
