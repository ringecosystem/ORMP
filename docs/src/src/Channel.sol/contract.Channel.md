# Channel
[Git Source](https://github.com/darwinia-network/ORMP/blob/bc92759f925cb7b2b882f5ab3b1cf34d66098e41/src/Channel.sol)

**Inherits:**
[UserConfig](/src/UserConfig.sol/contract.UserConfig.md)

A channel is a logical connection over cross-chain network.
It used for cross-chain message transfer.
- Accepts messages to be dispatched to remote chains,
constructs a Merkle tree of the messages.
- Dispatches verified messages from source chains.

*Messages live in an incremental merkle tree (imt)
> A Merkle tree is a binary and complete tree decorated with
> the Merkle (hash) attribute.*


## State Variables
### root
*Incremental merkle tree root which all message hashes live in leafs.*


```solidity
bytes32 public root;
```


### imt
*Incremental merkle tree.*


```solidity
IncrementalMerkleTree.Tree private imt;
```


### dones
*msgHash => isDispathed.*


```solidity
mapping(bytes32 => bool) public dones;
```


### _self
*Self contract address cache.*


```solidity
address private immutable _self = address(this);
```


## Functions
### constructor

*Init code.*


```solidity
constructor(address dao) UserConfig(dao);
```

### LOCAL_CHAINID

*Fetch local chain id.*


```solidity
function LOCAL_CHAINID() public view returns (uint256 chainId);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`chainId`|`uint256`|Local chain id.|


### _send

*Send message.*


```solidity
function _send(address from, uint256 toChainId, address to, bytes calldata encoded) internal returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|User application contract address which send the message.|
|`toChainId`|`uint256`|The Message destination chain id.|
|`to`|`address`|User application contract address which receive the message.|
|`encoded`|`bytes`|The calldata which encoded by ABI Encoding.|


### _recv

Only message.to's config relayer could relayer this message.

*Receive messages.*


```solidity
function _recv(Message calldata message, bytes calldata proof) internal returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`message`|`Message`|Received message info.|
|`proof`|`bytes`|Message proof of this message.|


### messageCount

*Fetch the messages count of incremental merkle tree.*


```solidity
function messageCount() public view returns (uint256);
```

### imtBranch

*Fetch the branch of incremental merkle tree.*


```solidity
function imtBranch() public view returns (bytes32[32] memory);
```

### prove

*Fetch the latest message proof*


```solidity
function prove() public view returns (bytes32[32] memory);
```

## Events
### MessageAccepted
*Notifies an observer that the message has been accepted.*


```solidity
event MessageAccepted(bytes32 indexed msgHash, bytes32 root, Message message);
```

### MessageDispatched
*Notifies an observer that the message has been dispatched.*


```solidity
event MessageDispatched(bytes32 indexed msgHash, bool dispatchResult);
```

