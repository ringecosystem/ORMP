# Oracle
[Git Source](https://github.com/darwinia-network/ORMP/blob/dc408522ef84e3f2da7fef5b81bd5e85c1a182a6/src/eco/Oracle.sol)

**Inherits:**
[Verifier](/src/Verifier.sol/abstract.Verifier.md)


## State Variables
### ENDPOINT

```solidity
address public immutable ENDPOINT;
```


### owner

```solidity
address public owner;
```


### feeOf

```solidity
mapping(uint256 => uint256) public feeOf;
```


### dapiOf

```solidity
mapping(uint256 => address) public dapiOf;
```


## Functions
### onlyOwner


```solidity
modifier onlyOwner();
```

### constructor


```solidity
constructor(address endpoint);
```

### receive


```solidity
receive() external payable;
```

### changeOwner


```solidity
function changeOwner(address owner_) external onlyOwner;
```

### withdraw


```solidity
function withdraw(uint256 amount) external onlyOwner;
```

### setFee


```solidity
function setFee(uint256 chainId, uint256 fee_) external onlyOwner;
```

### setDapi


```solidity
function setDapi(uint256 chainId, address dapi) external onlyOwner;
```

### fee


```solidity
function fee(uint256 toChainId, address) public view returns (uint256);
```

### assign


```solidity
function assign(bytes32 msgHash, uint256 toChainId, address) external payable returns (uint256);
```

### merkleRoot


```solidity
function merkleRoot(uint256 chainId) public view override returns (bytes32);
```

## Events
### Assigned

```solidity
event Assigned(bytes32 indexed msgHash);
```

### SetFee

```solidity
event SetFee(uint256 indexed chainId, uint256 fee);
```

### SetDapi

```solidity
event SetDapi(uint256 indexed chainId, address dapi);
```

