# IUserConfig
[Git Source](https://github.com/darwinia-network/ORMP/blob/5d245763e88118b1bc6b2cfd18dc541a2fe3481d/src/interfaces/IUserConfig.sol)


## Functions
### getAppConfig

If user application has not configured, then the default config is used.

*Fetch user application config.*


```solidity
function getAppConfig(address ua) external view returns (Config memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ua`|`address`|User application contract address.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`Config`|user application config.|


### setAppConfig

Set user application config.


```solidity
function setAppConfig(address oracle, address relayer) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`oracle`|`address`|Oracle which user application choose.|
|`relayer`|`address`|Relayer which user application choose.|


### setDefaultConfig


```solidity
function setDefaultConfig(address oracle, address relayer) external;
```

### defaultConfig


```solidity
function defaultConfig() external view returns (Config memory);
```

