# Application
[Git Source](https://github.com/darwinia-network/ORMP/blob/dc408522ef84e3f2da7fef5b81bd5e85c1a182a6/src/user/Application.sol)


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

