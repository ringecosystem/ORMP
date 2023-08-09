# Message
[Git Source](https://github.com/darwinia-network/ORMP/blob/39358390c194e135ecf3afba36ae9546a7f63b41/src/Common.sol)

*The block of control information and data for comminicate
between user applications. Messages are the exchange medium
used by channels to send and receive data through cross-chain networks.
A message is sent from a source chain to a destination chain.*


```solidity
struct Message {
    address channel;
    uint256 index;
    uint256 fromChainId;
    address from;
    uint256 toChainId;
    address to;
    bytes encoded;
}
```

