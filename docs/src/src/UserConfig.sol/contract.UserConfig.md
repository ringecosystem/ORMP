# UserConfig
[Git Source](https://github.com/darwinia-network/ORMP/blob/ea2cb1198288e52b94c992dab142e03eb3d0b767/src/UserConfig.sol)

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
constructor();
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
function setDefaultConfig(address relayer, address oracle) external onlySetter;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`relayer`|`address`|Default relayer.|
|`oracle`|`address`|Default oracle.|


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
|`oracle`|`address`|Oracle which user application.|


## Events
### SetDefaultConfig
*Notifies an observer that the default config has set.*


```solidity
event SetDefaultConfig(address relayer, address oracle);
```

### AppConfigUpdated
*Notifies an observer that the user application config has updated.*


```solidity
event AppConfigUpdated(address indexed ua, address relayer, address oracle);
```

