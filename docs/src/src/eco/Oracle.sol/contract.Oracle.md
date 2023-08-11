# Oracle
[Git Source](https://github.com/darwinia-network/ORMP/blob/5d245763e88118b1bc6b2cfd18dc541a2fe3481d/src/eco/Oracle.sol)

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

### isApproved


```solidity
function isApproved(address operator) public view returns (bool);
```

### setApproved


```solidity
function setApproved(address operator, bool approve) public onlyOwner;
```

### withdraw


```solidity
function withdraw(address to, uint256 amount) external onlyApproved;
```

### setFee


```solidity
function setFee(uint256 chainId, uint256 fee_) external onlyApproved;
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
function assign(bytes32 msgHash) external payable;
```

### merkleRoot


```solidity
function merkleRoot(uint256 chainId, uint256) public view override returns (bytes32);
```

## Events
### Assigned

```solidity
event Assigned(bytes32 indexed msgHash, uint256 fee);
```

### SetFee

```solidity
event SetFee(uint256 indexed chainId, uint256 fee);
```

### SetDapi

```solidity
event SetDapi(uint256 indexed chainId, address dapi);
```

### SetApproved

```solidity
event SetApproved(address operator, bool approve);
```

