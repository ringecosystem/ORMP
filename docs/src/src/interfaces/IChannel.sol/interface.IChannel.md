# IChannel
[Git Source](https://github.com/darwinia-network/ORMP/blob/ea2cb1198288e52b94c992dab142e03eb3d0b767/src/interfaces/IChannel.sol)


## Functions
### sendMessage


```solidity
function sendMessage(address from, uint256 toChainId, address to, bytes calldata encoded) external returns (bytes32);
```

### recvMessage


```solidity
function recvMessage(Message calldata message, bytes calldata proof) external;
```

