# ReentrancyGuard
[Git Source](https://github.com/darwinia-network/ORMP/blob/28f242d61f8f1de9729b61a20924f3f1938d1e53/src/security/ReentrancyGuard.sol)


## State Variables
### _NOT_ENTERED

```solidity
uint8 internal constant _NOT_ENTERED = 1;
```


### _ENTERED

```solidity
uint8 internal constant _ENTERED = 2;
```


### _send_state

```solidity
uint8 internal _send_state = 1;
```


### _receive_state

```solidity
uint8 internal _receive_state = 1;
```


## Functions
### sendNonReentrant


```solidity
modifier sendNonReentrant();
```

### recvNonReentrant


```solidity
modifier recvNonReentrant();
```

