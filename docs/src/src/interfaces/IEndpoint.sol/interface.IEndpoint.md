# IEndpoint
[Git Source](https://github.com/darwinia-network/ORMP/blob/bfc33075bd9a7ec216d3d5b5407194e8cde9bd94/src/interfaces/IEndpoint.sol)


## Functions
### send

follow https://eips.ethereum.org/EIPS/eip-5750

*Send a cross-chain message over the endpoint.*


```solidity
function send(uint256 toChainId, address to, bytes calldata encoded, bytes calldata params)
    external
    payable
    returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`toChainId`|`uint256`|The Message destination chain id.|
|`to`|`address`|User application contract address which receive the message.|
|`encoded`|`bytes`|The calldata which encoded by ABI Encoding.|
|`params`|`bytes`|General extensibility for relayer to custom functionality.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|Return the hash of the message as message id.|


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

*Recv verified message and dispatch to destination user application address.*


```solidity
function recv(Message calldata message, bytes calldata proof, uint256 gasLimit)
    external
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


### prove


```solidity
function prove() external view returns (bytes32[32] memory);
```

### getAppConfig

If user application has not configured, then the default config is used.

*Fetch user application config.*


```solidity
function getAppConfig(address ua) external view returns (Config memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ua`|`address`|User application contract address.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`Config`|user application config.|


### setAppConfig

Set user application config.


```solidity
function setAppConfig(address oracle, address relayer) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`oracle`|`address`|Oracle which user application choose.|
|`relayer`|`address`|Relayer which user application choose.|


### setDefaultConfig


```solidity
function setDefaultConfig(address oracle, address relayer) external;
```

### defaultConfig


```solidity
function defaultConfig() external view returns (Config memory);
```

### changeSetter


```solidity
function changeSetter(address setter_) external;
```

