# ReentrancyGuard
[Git Source](https://github.com/darwinia-network/ORMP/blob/ee39b68e9de8fcd65763e52aec00c1d9ff4831db/src/security/ReentrancyGuard.sol)


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

