.PHONY: add clean test
dapp ?= forge
all    :; $(dapp) build
clean  :; $(dapp) clean
test   :; $(dapp) test
