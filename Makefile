.PHONY: add clean test

dapp ?= dapp
all    :; $(dapp) build
clean  :; $(dapp) clean
test   :; $(dapp) test
deploy :; $(dapp) create ChannelTest
