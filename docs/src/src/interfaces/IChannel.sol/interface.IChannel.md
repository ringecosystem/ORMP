# IChannel
[Git Source](https://github.com/darwinia-network/ORMP/blob/5d245763e88118b1bc6b2cfd18dc541a2fe3481d/src/interfaces/IChannel.sol)


## Functions
### sendMessage


```solidity
function sendMessage(address from, uint256 toChainId, address to, bytes calldata encoded) external returns (bytes32);
```

### recvMessage


```solidity
function recvMessage(Message calldata message, bytes calldata proof, uint256 gasLimit) external;
```

