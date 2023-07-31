.PHONY: add clean test deploy doc

dapp ?= dapp
all    :; $(dapp) build
clean  :; $(dapp) clean
test   :; $(dapp) test
deploy :; $(dapp) create ChannelTest
doc    :; @bash ./bin/doc.sh
