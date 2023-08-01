# IEndpoint
[Git Source](https://github.com/darwinia-network/ORMP/blob/4f7e50a941e561ca86840d800b02ebd892a72255/src/interfaces/IEndpoint.sol)


## Functions
### send

follow https://eips.ethereum.org/EIPS/eip-5750

*Send a cross-chain message over the endpoint.*


```solidity
function send(uint256 toChainId, address to, bytes calldata encoded, bytes calldata params) external payable;
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
function fee(uint256 toChainId, address, bytes calldata encoded, bytes calldata params) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`toChainId`|`uint256`|The Message destination chain id.|
|`<none>`|`address`||
|`encoded`|`bytes`|The calldata which encoded by ABI Encoding.|
|`params`|`bytes`|General extensibility for relayer to custom functionality.|


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


### retryFailedMessage

*Retry failed message.*


```solidity
function retryFailedMessage(Message calldata message) external returns (bool dispatchResult);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`message`|`Message`|Failed message info.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`dispatchResult`|`bool`|Result of the message dispatch.|


### recv


```solidity
function recv(Message calldata message) external returns (bool dispatchResult);
```

