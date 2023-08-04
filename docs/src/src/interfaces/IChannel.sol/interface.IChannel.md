# IChannel
[Git Source](https://github.com/darwinia-network/ORMP/blob/39358390c194e135ecf3afba36ae9546a7f63b41/src/interfaces/IChannel.sol)


## Functions
### sendMessage


```solidity
function sendMessage(address from, uint256 toChainId, address to, bytes calldata encoded) external returns (bytes32);
```

### recvMessage


```solidity
function recvMessage(Message calldata message, bytes calldata proof) external;
```

