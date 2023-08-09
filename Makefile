.PHONY: add clean test deploy doc

-include .env

dapp ?= forge
all    :; $(dapp) build
clean  :; $(dapp) clean
test   :; $(dapp) test
sync   :; $(dapp) script script/deploy/Deploy.s.sol --sig "sync()" --chain-id ${chain-id}
deploy :; $(dapp) script script/deploy/Deploy.s.sol --chain-id ${chain-id} --broadcast


doc    :; @bash ./bin/doc.sh
