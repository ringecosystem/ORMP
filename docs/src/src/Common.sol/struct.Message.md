# Message
[Git Source](https://github.com/darwinia-network/ORMP/blob/dc408522ef84e3f2da7fef5b81bd5e85c1a182a6/src/Common.sol)

*The block of control information and data for comminicate
between user applications. Messages are the exchange medium
used by channels to send and receive data through cross-chain networks.
A message is sent from a source chain to a destination chain.*


```solidity
struct Message {
    uint256 index;
    uint256 fromChainId;
    address from;
    uint256 toChainId;
    address to;
    bytes encoded;
}
```

