# IVerifier
[Git Source](https://github.com/darwinia-network/ORMP/blob/bc92759f925cb7b2b882f5ab3b1cf34d66098e41/src/interfaces/IVerifier.sol)


## Functions
### verifyMessageProof

Verify message proof

*Message proof provided by relayer. Oracle should provide message root of
source chain, and verify the merkle proof of the message hash.*


```solidity
function verifyMessageProof(uint256 fromChainId, bytes32 msgHash, bytes calldata proof) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`fromChainId`|`uint256`|Source chain id.|
|`msgHash`|`bytes32`|Hash of the message.|
|`proof`|`bytes`|Merkle proof of the message|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Result of the message verify.|


