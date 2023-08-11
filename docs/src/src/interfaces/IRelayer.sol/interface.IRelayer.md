# IRelayer
[Git Source](https://github.com/darwinia-network/ORMP/blob/5d245763e88118b1bc6b2cfd18dc541a2fe3481d/src/interfaces/IRelayer.sol)


## Functions
### fee

Fetch relayer price to relay message to the destination chain.


```solidity
function fee(uint256 toChainId, address ua, uint256 size, bytes calldata params) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`toChainId`|`uint256`|The destination chain id.|
|`ua`|`address`|The user application which send the message.|
|`size`|`uint256`|The size of message encoded payload.|
|`params`|`bytes`|General extensibility for relayer to custom functionality.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Relayer price in source native gas.|


### assign

Assign the relay message task to relayer maintainer.


```solidity
function assign(bytes32 msgHash, bytes calldata params) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`msgHash`|`bytes32`|Hash of the message.|
|`params`|`bytes`|General extensibility for relayer to custom functionality.|


