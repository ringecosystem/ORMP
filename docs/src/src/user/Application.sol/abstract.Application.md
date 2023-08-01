# Application
[Git Source](https://github.com/darwinia-network/ORMP/blob/ea2cb1198288e52b94c992dab142e03eb3d0b767/src/user/Application.sol)


## State Variables
### TRUSTED_ENDPOINT

```solidity
address public immutable TRUSTED_ENDPOINT;
```


## Functions
### constructor


```solidity
constructor(address endpoint);
```

### clearFailedMessage


```solidity
function clearFailedMessage(Message calldata message) external virtual;
```

### retryFailedMessage


```solidity
function retryFailedMessage(Message calldata message) external virtual returns (bool dispatchResult);
```

### setAppConfig


```solidity
function setAppConfig(address relayer, address oracle) external virtual;
```

### isTrustedEndpoint


```solidity
function isTrustedEndpoint(address endpoint) public view returns (bool);
```

### _messageId


```solidity
function _messageId() internal pure returns (bytes32 _msgDataMessageId);
```

### _fromChainId


```solidity
function _fromChainId() internal pure returns (uint256 _msgDataFromChainId);
```

### _xmsgSender


```solidity
function _xmsgSender() internal view returns (address payable _from);
```

