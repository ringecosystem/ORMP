// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

struct Request {
    // Currently, aggregators is deployed on Near. So use `string` type.
    string aggregator;
    // JSON string
    string requestData;
    address requester;
    address callbackContract;
    bytes4 callbackFunction;
    RequestStatus status;
    // Derived address of aggregator account (on near)
    address exAggregator;
    ResponseData response;
    uint256 reportersFee;
    uint256 publishFee;
}

enum RequestStatus {
    Pending,
    Fulfilled,
    CallbackFailed
}

struct ResponseData {
    address[] reporters;
    bytes result;
    // 0 if no error
    uint16 errorCode;
}

struct AggregatorConfig {
    // Aggregator account on near
    string aggregator;
    address rewardAddress;
    uint256 reportersFee;
    uint256 publishFee;
    uint256 version;
    bool suspended;
}

interface IXAPI {
    event RequestMade(
        uint256 indexed requestId,
        string aggregator,
        string requestData,
        address indexed requester,
        address indexed exAggregator,
        uint256 reportersFee,
        uint256 publishFee
    );
    event Fulfilled(uint256 indexed requestId, ResponseData response, RequestStatus indexed status);
    event RewardsWithdrawn(address indexed withdrawer, uint256 amount);
    event AggregatorConfigSet(
        address indexed exAggregator,
        uint256 reportersFee,
        uint256 publishFee,
        string aggregator,
        address rewardAddress,
        uint256 version
    );
    event AggregatorSuspended(address indexed exAggregator, string indexed aggregator);

    function makeRequest(address exAggregator, string memory requestData, bytes4 callbackFunction)
        external
        payable
        returns (uint256);

    function fulfill(uint256 requestId, ResponseData memory response) external;

    function retryFulfill(uint256 requestId) external;

    function withdrawRewards() external;

    // Should be called by Aggregator mpc
    function setAggregatorConfig(
        string memory aggregator,
        uint256 reportersFee,
        uint256 publishFee,
        address rewardAddress,
        uint256 version
    ) external;

    function fee(address exAggregator) external view returns (uint256);

    function suspendAggregator(address exAggregator) external;
}
