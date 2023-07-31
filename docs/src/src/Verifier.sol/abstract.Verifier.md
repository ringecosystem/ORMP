# Verifier
[Git Source](https://github.com/darwinia-network/ORMP/blob/dc408522ef84e3f2da7fef5b81bd5e85c1a182a6/src/Verifier.sol)

**Inherits:**
[IVerifier](/src/interfaces/IVerifier.sol/interface.IVerifier.md)


## Functions
### merkleRoot

Fetch message root oracle.


```solidity
function merkleRoot(uint256 chainId) public view virtual returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`chainId`|`uint256`|The destination chain id.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|Message root in destination chain.|


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


## Structs
### Proof
Message proof.


```solidity
struct Proof {
    uint256 messageIndex;
    bytes32[32] messageProof;
}
```

