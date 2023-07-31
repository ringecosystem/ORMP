# IChannel
[Git Source](https://github.com/darwinia-network/ORMP/blob/ee39b68e9de8fcd65763e52aec00c1d9ff4831db/src/interfaces/IChannel.sol)


## Functions
### sendMessage


```solidity
function sendMessage(address from, uint256 toChainId, address to, bytes calldata encoded) external returns (bytes32);
```

### recvMessage


```solidity
function recvMessage(Message calldata message, bytes calldata proof) external;
```

