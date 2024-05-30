.PHONY: all clean test bench deploy fmt sync
.PHONY: doc salt tools foundry fee config verify create3

-include .env

all    :; @forge build
clean  :; @forge clean
fmt    :; @forge fmt
test   :; @forge test --nmc Benchmark
bench  :; @forge test --mc Benchmark

tools  :  foundry
foundry:; curl -L https://foundry.paradigm.xyz | bash
create3:; @cargo install --git https://github.com/darwinia-network/create3-deploy -f --locked
sync   :; @git submodule update --recursive

doc    :; @bash ./bin/doc.sh
salt   :; @create3 -s 00000000000000
deploy :; @bash ./bin/deploy.sh
fee    :; @bash ./bin/fee.sh
config :; @bash ./bin/config.sh
verify :; @bash ./bin/verify.sh
