# Application
[Git Source](https://github.com/darwinia-network/ORMP/blob/bfc33075bd9a7ec216d3d5b5407194e8cde9bd94/src/user/Application.sol)


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

