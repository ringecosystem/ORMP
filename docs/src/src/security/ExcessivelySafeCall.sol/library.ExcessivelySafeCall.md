# ExcessivelySafeCall
[Git Source](https://github.com/darwinia-network/ORMP/blob/bfc33075bd9a7ec216d3d5b5407194e8cde9bd94/src/security/ExcessivelySafeCall.sol)


## State Variables
### LOW_28_MASK

```solidity
uint256 internal constant LOW_28_MASK = 0x00000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
```


## Functions
### excessivelySafeCall

Use when you _really_ really _really_ don't trust the called
contract. This prevents the called contract from causing reversion of
the caller in as many ways as we can.

*The main difference between this and a solidity low-level call is
that we limit the number of bytes that the callee can cause to be
copied to caller memory. This prevents stupid things like malicious
contracts returning 10,000,000 bytes causing a local OOG when copying
to memory.*


```solidity
function excessivelySafeCall(address _target, uint256 _gas, uint16 _maxCopy, bytes memory _calldata)
    internal
    returns (bool, bytes memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_target`|`address`|The address to call|
|`_gas`|`uint256`|The amount of gas to forward to the remote contract|
|`_maxCopy`|`uint16`|The maximum number of bytes of returndata to copy to memory.|
|`_calldata`|`bytes`|The data to send to the remote contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success and returndata, as `.call()`. Returndata is capped to `_maxCopy` bytes.|
|`<none>`|`bytes`||


### excessivelySafeStaticCall

Use when you _really_ really _really_ don't trust the called
contract. This prevents the called contract from causing reversion of
the caller in as many ways as we can.

*The main difference between this and a solidity low-level call is
that we limit the number of bytes that the callee can cause to be
copied to caller memory. This prevents stupid things like malicious
contracts returning 10,000,000 bytes causing a local OOG when copying
to memory.*


```solidity
function excessivelySafeStaticCall(address _target, uint256 _gas, uint16 _maxCopy, bytes memory _calldata)
    internal
    view
    returns (bool, bytes memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_target`|`address`|The address to call|
|`_gas`|`uint256`|The amount of gas to forward to the remote contract|
|`_maxCopy`|`uint16`|The maximum number of bytes of returndata to copy to memory.|
|`_calldata`|`bytes`|The data to send to the remote contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success and returndata, as `.call()`. Returndata is capped to `_maxCopy` bytes.|
|`<none>`|`bytes`||


### swapSelector

Swaps function selectors in encoded contract calls

*Allows reuse of encoded calldata for functions with identical
argument types but different names. It simply swaps out the first 4 bytes
for the new selector. This function modifies memory in place, and should
only be used with caution.*


```solidity
function swapSelector(bytes4 _newSelector, bytes memory _buf) internal pure;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newSelector`|`bytes4`|The new 4-byte selector|
|`_buf`|`bytes`|The encoded contract args|


