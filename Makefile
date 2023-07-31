.PHONY: add clean test doc

dapp ?= dapp
all    :; $(dapp) build
clean  :; $(dapp) clean
test   :; $(dapp) test
deploy :; $(dapp) create ChannelTest
doc    :; @./bin/doc.sh
