GETH_PACKAGE:=geth-alltools-darwin-amd64-1.7.2-1db4ecdc
GETH:=bin/geth --networkid=9999 --verbosity=4 --ethash.dagdir=.dagdir --nodiscover
GETH_INIT:=bin/geth init genesis.json

# node keys
NODE1_KEY:=cea538a9436228454032f233756429f6dc1c59e73213d5637928647b85047e1d
MINER1_KEY:=ec40c37172e48dc312a7254d728629b7d66182912fbfc602561aad2fe782b6e7
MINER2_KEY:=e0463fc7d3af3bfe2cd76207572a9500c8173a59cb43e39bdea22ce6dd1ea3f8

.PHONY: clean
clean:
	rm -rf node1 miner1 miner2

.PHONY: rebuild
rebuild: clean setup

.PHONY: setup
setup: node1 miner1 miner2

.PHONY: geth
geth:
	rm -f geth.tar.gz
	curl https://gethstore.blob.core.windows.net/builds/$(GETH_PACKAGE).tar.gz -o geth.tar.gz
	tar -xzvf geth.tar.gz
	mv $(GETH_PACKAGE) bin
	rm -fr $(GETH_PACKAGE) geth.tar.gz

.PHONY: node1
node1:
	$(GETH_INIT) --datadir=node1
	echo "$(NODE1_KEY)" | tee node1/geth/nodekey
	cat static/node1.json | tee node1/static-nodes.json
	cp accounts/user1 node1/keystore/

.PHONY: run-node1
run-node1:
	$(GETH) --datadir=node1 --port 9001

.PHONY: console-node1
console-node1:
	$(GETH) attach node1/geth.ipc

.PHONY: miner1
miner1:
	$(GETH_INIT) --datadir=miner1
	echo "$(MINER1_KEY)" | tee miner1/geth/nodekey
	cat static/miner1.json | tee miner1/static-nodes.json

.PHONY: run-miner1
run-miner1:
	$(GETH) --datadir=miner1 \
		--port 8001 \
		--mine \
		--minerthreads=1 \
		--etherbase=fe6a3804c1fe325c8ed6c9fa406224b7be92b1f8

.PHONY: miner2
miner2:
	$(GETH_INIT) --datadir=miner2
	echo "$(MINER2_KEY)" | tee miner2/geth/nodekey
	cat static/miner2.json | tee miner2/static-nodes.json

.PHONY: run-miner2
run-miner2:
	$(GETH) --datadir=miner2 \
		--port 8002 \
		--mine \
		--minerthreads=1 \
		--etherbase=65841dd2b3f5287a6dc0a939cde25b32bc883419
