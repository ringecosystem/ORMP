# Application
[Git Source](https://github.com/darwinia-network/ORMP/blob/bc92759f925cb7b2b882f5ab3b1cf34d66098e41/src/user/Application.sol)


## State Variables
### TRUSTED_ORMP

```solidity
address public immutable TRUSTED_ORMP;
```


## Functions
### constructor


```solidity
constructor(address ormp);
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

### isTrustedORMP


```solidity
function isTrustedORMP(address ormp) public view returns (bool);
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

