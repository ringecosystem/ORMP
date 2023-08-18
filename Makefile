.PHONY: add clean test sync deploy doc salt
.PHONY: tools foundry

-include .env

all    :; forge build
clean  :; forge clean
test   :; forge test
deploy :; forge script script/deploy/Deploy.s.sol:Deploy --chain-id ${chain-id} --broadcast --verify

tools  :; foundry
foundry:; curl -L https://foundry.paradigm.xyz | bash

doc    :; @bash ./bin/doc.sh
salt   :; @bash ./bin/salt.sh
