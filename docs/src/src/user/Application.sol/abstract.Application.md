# Application
[Git Source](https://github.com/darwinia-network/ORMP/blob/4f7e50a941e561ca86840d800b02ebd892a72255/src/user/Application.sol)


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

