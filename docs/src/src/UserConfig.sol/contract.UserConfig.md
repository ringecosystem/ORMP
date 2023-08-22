# UserConfig
[Git Source](https://github.com/darwinia-network/ORMP/blob/bfc33075bd9a7ec216d3d5b5407194e8cde9bd94/src/UserConfig.sol)

User config could select their own relayer and oracle.
The default configuration is used by default.

*Only setter could set default config.*


## State Variables
### setter
*Setter address.*


```solidity
address public setter;
```


### appConfig
*ua => config.*


```solidity
mapping(address => Config) public appConfig;
```


### defaultConfig
*Default config.*


```solidity
Config public defaultConfig;
```


## Functions
### onlySetter


```solidity
modifier onlySetter();
```

### constructor


```solidity
constructor(address dao);
```

### changeSetter

Only current setter could call.

*Change setter.*


```solidity
function changeSetter(address setter_) external onlySetter;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`setter_`|`address`|New setter.|


### setDefaultConfig

Only setter could call.

*Set default config for all application.*


```solidity
function setDefaultConfig(address oracle, address relayer) external onlySetter;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`oracle`|`address`|Default oracle.|
|`relayer`|`address`|Default relayer.|


### getDefaultConfig


```solidity
function getDefaultConfig() external view returns (Config memory);
```

### getAppConfig

If user application has not configured, then the default config is used.

*Fetch user application config.*


```solidity
function getAppConfig(address ua) public view returns (Config memory);
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
|`oracle`|`address`|Oracle which user application.|
|`relayer`|`address`|Relayer which user application choose.|


## Events
### SetDefaultConfig
*Notifies an observer that the default config has set.*


```solidity
event SetDefaultConfig(address oracle, address relayer);
```

### AppConfigUpdated
*Notifies an observer that the user application config has updated.*


```solidity
event AppConfigUpdated(address indexed ua, address oracle, address relayer);
```

