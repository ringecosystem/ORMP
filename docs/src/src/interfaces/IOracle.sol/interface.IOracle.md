# IOracle
[Git Source](https://github.com/darwinia-network/ORMP/blob/39358390c194e135ecf3afba36ae9546a7f63b41/src/interfaces/IOracle.sol)


## Functions
### fee

Fetch oracle price to relay message root to the destination chain.


```solidity
function fee(uint256 toChainId, address ua) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`toChainId`|`uint256`|The destination chain id.|
|`ua`|`address`|The user application which send the message.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Oracle price in source native gas.|


### assign

Assign the relay message root task to oracle maintainer.


```solidity
function assign(bytes32 msgHash) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`msgHash`|`bytes32`|Hash of the message.|


### merkleRoot

Fetch message root oracle.


```solidity
function merkleRoot(uint256 chainId) external view returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`chainId`|`uint256`|The destination chain id.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|Message root in destination chain.|


