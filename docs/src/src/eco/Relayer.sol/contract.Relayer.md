# Relayer
[Git Source](https://github.com/darwinia-network/ORMP/blob/ea2cb1198288e52b94c992dab142e03eb3d0b767/src/eco/Relayer.sol)


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
mapping(uint32 => Price) public priceOf;
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

### setPrice


```solidity
function setPrice(uint32 chainId, uint64 benchGas, uint64 baseGas, uint64 gasPerByte) external onlyApproved;
```

### withdraw


```solidity
function withdraw(address to, uint256 amount) external onlyApproved;
```

### fee


```solidity
function fee(uint32 toChainId, address, uint256 size, bytes calldata params) public view returns (uint256);
```

### assign


```solidity
function assign(bytes32 msgHash, uint32 toChainId, address ua, uint256 size, bytes calldata params)
    external
    payable
    returns (uint256);
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

### SetPrice

```solidity
event SetPrice(uint32 indexed chainId, uint64 benchGas, uint64 baseGas, uint64 gasPerByte);
```

### SetApproved

```solidity
event SetApproved(address relayer, bool approve);
```

## Structs
### Price

```solidity
struct Price {
    uint64 benchGas;
    uint64 baseGas;
    uint64 gasPerByte;
}
```

