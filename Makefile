.PHONY: add clean test deploy doc

-include .env

dapp ?= forge
all    :; $(dapp) build
clean  :; $(dapp) clean
test   :; $(dapp) test
sync   :; $(dapp) script script/deploy/Deploy.s.sol:Deploy --sig "sync()" --chain-id ${chain-id}
deploy :; $(dapp) script script/deploy/Deploy.s.sol:Deploy --chain-id ${chain-id} --broadcast --verify


doc    :; @bash ./bin/doc.sh
