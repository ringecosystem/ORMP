# Application
[Git Source](https://github.com/darwinia-network/ORMP/blob/39358390c194e135ecf3afba36ae9546a7f63b41/src/user/Application.sol)


## State Variables
### USER_CONFIG

```solidity
address public immutable USER_CONFIG;
```


### TRUSTED_ENDPOINT

```solidity
address public immutable TRUSTED_ENDPOINT;
```


## Functions
### constructor


```solidity
constructor(address config, address endpoint);
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

