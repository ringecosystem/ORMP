# Relayer
[Git Source](https://github.com/darwinia-network/ORMP/blob/bc92759f925cb7b2b882f5ab3b1cf34d66098e41/src/eco/Relayer.sol)


## State Variables
### PROTOCOL

```solidity
address public immutable PROTOCOL;
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
constructor(address dao, address ormp);
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
function isApproved(address operator) public view returns (bool);
```

### setApproved


```solidity
function setApproved(address operator, bool approve) public onlyOwner;
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
function assign(bytes32 msgHash, bytes calldata params) external payable;
```

### relay


```solidity
function relay(Message calldata message, bytes calldata proof, uint256 gasLimit) external onlyApproved;
```

## Events
### Assigned

```solidity
event Assigned(bytes32 indexed msgHash, uint256 fee, bytes params, bytes32[32] proof);
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
event SetApproved(address operator, bool approve);
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

