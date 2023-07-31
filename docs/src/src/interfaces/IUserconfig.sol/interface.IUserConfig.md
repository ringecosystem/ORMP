# IUserConfig
[Git Source](https://github.com/darwinia-network/ORMP/blob/dc408522ef84e3f2da7fef5b81bd5e85c1a182a6/src/interfaces/IUserconfig.sol)


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
function setAppConfig(address relayer, address oracle) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`relayer`|`address`|Relayer which user application choose.|
|`oracle`|`address`|Oracle which user application choose.|


