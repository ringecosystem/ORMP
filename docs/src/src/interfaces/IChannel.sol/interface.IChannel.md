# IChannel
[Git Source](https://github.com/darwinia-network/ORMP/blob/dc408522ef84e3f2da7fef5b81bd5e85c1a182a6/src/interfaces/IChannel.sol)


## Functions
### sendMessage


```solidity
function sendMessage(address from, uint256 toChainId, address to, bytes calldata encoded) external returns (bytes32);
```

### recvMessage


```solidity
function recvMessage(Message calldata message, bytes calldata proof) external;
```

