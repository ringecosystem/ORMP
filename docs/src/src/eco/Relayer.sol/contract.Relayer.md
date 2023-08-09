# Relayer
[Git Source](https://github.com/darwinia-network/ORMP/blob/39358390c194e135ecf3afba36ae9546a7f63b41/src/eco/Relayer.sol)


## State Variables
### ENDPOINT

```solidity
address public immutable ENDPOINT;
```


### CHANNEL

```solidity
address public immutable CHANNEL;
```


### owner

```solidity
address public owner;
```


### priceOf

```solidity
mapping(uint256 => DstPrice) public priceOf;
```


### configOf

```solidity
mapping(uint256 => DstConfig) public configOf;
```


### approvedOf

```solidity
mapping(address => bool) public approvedOf;
```


## Functions
### onlyOwner


```solidity
modifier onlyOwner();
```

### onlyApproved


```solidity
modifier onlyApproved();
```

### constructor


```solidity
constructor(address endpoint, address channel);
```

### receive


```solidity
receive() external payable;
```

### changeOwner


```solidity
function changeOwner(address owner_) external onlyOwner;
```

### isApproved


```solidity
function isApproved(address relayer) public view returns (bool);
```

### setApproved


```solidity
function setApproved(address relayer, bool approve) public onlyOwner;
```

### setDstPrice


```solidity
function setDstPrice(uint256 chainId, uint128 dstPriceRatio, uint128 dstGasPriceInWei) external onlyApproved;
```

### setDstConfig


```solidity
function setDstConfig(uint256 chainId, uint64 baseGas, uint64 gasPerByte) external onlyApproved;
```

### withdraw


```solidity
function withdraw(address to, uint256 amount) external onlyApproved;
```

### fee


```solidity
function fee(uint256 toChainId, address, uint256 size, bytes calldata params) public view returns (uint256);
```

### assign


```solidity
function assign(bytes32 msgHash) external payable;
```

### relay


```solidity
function relay(Message calldata message, bytes calldata proof) external onlyApproved;
```

## Events
### Assigned

```solidity
event Assigned(bytes32 indexed msgHash, uint256 fee);
```

### SetDstPrice

```solidity
event SetDstPrice(uint256 indexed chainId, uint128 dstPriceRatio, uint128 dstGasPriceInWei);
```

### SetDstConfig

```solidity
event SetDstConfig(uint256 indexed chainId, uint64 baseGas, uint64 gasPerByte);
```

### SetApproved

```solidity
event SetApproved(address relayer, bool approve);
```

## Structs
### DstPrice

```solidity
struct DstPrice {
    uint128 dstPriceRatio;
    uint128 dstGasPriceInWei;
}
```

### DstConfig

```solidity
struct DstConfig {
    uint64 baseGas;
    uint64 gasPerByte;
}
```

