# ORMP
[Git Source](https://github.com/darwinia-network/ORMP/blob/bfc33075bd9a7ec216d3d5b5407194e8cde9bd94/src/ORMP.sol)

**Inherits:**
[ReentrancyGuard](/src/security/ReentrancyGuard.sol/abstract.ReentrancyGuard.md), [Channel](/src/Channel.sol/contract.Channel.md)

An endpoint is a type of network node for cross-chain communication.
It is an interface exposed by a communication channel.

*An endpoint is associated with an immutable channel and user configuration.*


## State Variables
### fails
msgHash => isFailed


```solidity
mapping(bytes32 => bool) public fails;
```


## Functions
### constructor


```solidity
constructor(address dao) Channel(dao);
```

### send

follow https://eips.ethereum.org/EIPS/eip-5750

*Send a cross-chain message over the endpoint.*


```solidity
function send(uint256 toChainId, address to, bytes calldata encoded, bytes calldata params)
    external
    payable
    sendNonReentrant
    returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`toChainId`|`uint256`|The Message destination chain id.|
|`to`|`address`|User application contract address which receive the message.|
|`encoded`|`bytes`|The calldata which encoded by ABI Encoding.|
|`params`|`bytes`|General extensibility for relayer to custom functionality.|


### fee

Get a quote in source native gas, for the amount that send() requires to pay for message delivery.


```solidity
function fee(uint256 toChainId, address, bytes calldata encoded, bytes calldata params)
    external
    view
    returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`toChainId`|`uint256`|The Message destination chain id.|
|`<none>`|`address`||
|`encoded`|`bytes`|The calldata which encoded by ABI Encoding.|
|`params`|`bytes`|General extensibility for relayer to custom functionality.|


### _handleRelayer


```solidity
function _handleRelayer(
    address relayer,
    bytes32 msgHash,
    uint256 toChainId,
    address ua,
    uint256 size,
    bytes calldata params
) internal returns (uint256);
```

### _handleOracle


```solidity
function _handleOracle(address oracle, bytes32 msgHash, uint256 toChainId, address ua) internal returns (uint256);
```

### recv

Only channel could call this function.

*Recv verified message from Channel and dispatch to destination user application address.*


```solidity
function recv(Message calldata message, bytes calldata proof, uint256 gasLimit)
    external
    recvNonReentrant
    returns (bool dispatchResult);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`message`|`Message`|Verified receive message info.|
|`proof`|`bytes`|Message proof of this message.|
|`gasLimit`|`uint256`|The gas limit of message execute.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`dispatchResult`|`bool`|Result of the message dispatch.|


### retryFailedMessage

*Retry failed message.*


```solidity
function retryFailedMessage(Message calldata message) external recvNonReentrant returns (bool dispatchResult);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`message`|`Message`|Failed message info.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`dispatchResult`|`bool`|Result of the message dispatch.|


### clearFailedMessage

Only message.to could clear this message.

*Retry failed message.*


```solidity
function clearFailedMessage(Message calldata message) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`message`|`Message`|Failed message info.|


### _dispatch

*Dispatch the cross chain message.*


```solidity
function _dispatch(Message memory message, bytes32 msgHash, uint256 gasLimit) private returns (bool dispatchResult);
```

## Events
### ClearFailedMessage
*Notifies an observer that the failed message has been cleared.*


```solidity
event ClearFailedMessage(bytes32 indexed msgHash);
```

### RetryFailedMessage
*Notifies an observer that the failed message has been retried.*


```solidity
event RetryFailedMessage(bytes32 indexed msgHash, bool dispatchResult);
```

