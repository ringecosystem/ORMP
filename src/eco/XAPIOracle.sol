// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Verifier.sol";
import "../interfaces/IORMP.sol";
import "xapi-consumer/interfaces/IXAPIConsumer.sol";
import "xapi/contracts/lib/XAPIBuilder.sol";

contract XAPIOracle is Verifier, IXAPIConsumer {
    using XAPIBuilder for XAPIBuilder.Request;

    event SetFee(uint256 indexed chainId, uint256 fee);
    event SetApproved(address operator, bool approve);
    event Withdrawal(address indexed to, uint256 amt);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event XAPIRequestMade(uint256 indexed requestId, XAPIBuilder.Request requestData);
    event XAPIConsumeResult(uint256 indexed requestId, bytes responseData, uint16 errorCode);
    event XAPIConsumeError(uint256 indexed requestId, uint16 errorCode);

    address public immutable PROTOCOL;
    address public immutable XAPI;
    address public immutable EXAGGREGATOR;

    address public owner;
    // chainId => price
    mapping(uint256 => uint256) public feeOf;
    // operator => isApproved
    mapping(address => bool) public approvedOf;

    struct DataSource {
        string name;
        string url;
        string method;
        string resultPath;
    }

    uint256 requestId;

    modifier onlyOwner() {
        require(msg.sender == owner, "!owner");
        _;
    }

    modifier onlyXAPI() {
        require(msg.sender == XAPI, "!xapi");
        _;
    }

    modifier onlyApproved() {
        require(isApproved(msg.sender), "!approve");
        _;
    }

    constructor(address dao, address ormp, address xapi, address exagg) {
        PROTOCOL = ormp;
        owner = dao;
        XAPI = xapi;
        EXAGGREGATOR = exagg;
    }

    receive() external payable {}

    function version() public pure returns (string memory) {
        return "1.0.0";
    }

    function _buildRequest(uint256 chainId, address channel, uint256 msgIndex)
        internal
        view
        returns (XAPIBuilder.Request memory)
    {
        XAPIBuilder.Request memory requestData;
        requestData._initialize(EXAGGREGATOR, this.xapiCallback.selector);
        requestData._addParamUint("_dataSources", chainId);
        requestData._startNestedParam("*");
        {
            requestData._startNestedParam("variables");
            {
                requestData._addParamUint("chainId", chainId);
                requestData._addParamBytes("channel", abi.encodePacked(channel));
                requestData._addParamUint("msgIndex", msgIndex);
            }
            requestData._endNestedParam();
        }
        requestData._endNestedParam();
        return requestData;
    }

    /// @dev Only could be called by approved address.
    /// @param chainId The request source chain id.
    /// @param channel The request message channel.
    /// @param msgIndex The request message index.
    function makeRequestForMessageHash(uint256 chainId, address channel, uint256 msgIndex)
        external
        payable
        onlyApproved
    {
        XAPIBuilder.Request memory requestData = _buildRequest(chainId, channel, msgIndex);
        uint256 fee_ = IXAPI(XAPI).fee(EXAGGREGATOR);
        require(msg.value == fee_, "!fee");
        requestId = IXAPI(XAPI).makeRequest{value: fee_}(requestData);
        emit XAPIRequestMade(requestId, requestData);
    }

    function xapiCallback(uint256 requestId_, ResponseData memory response) external onlyXAPI {
        require(requestId_ == requestId, "!requestId");
        if (response.errorCode != 0) {
            (uint256 chainId, address channel, uint256 msgIndex, bytes32 msgHash) =
                abi.decode(response.result, (uint256, address, uint256, bytes32));
            IORMP(PROTOCOL).importHash(chainId, channel, msgIndex, msgHash);
            emit XAPIConsumeResult(requestId, response.result, response.errorCode);
        } else {
            emit XAPIConsumeError(requestId, response.errorCode);
        }
    }

    function hashOf(uint256 chainId, address channel, uint256 msgIndex) public view override returns (bytes32) {
        return IORMP(PROTOCOL).hashLookup(address(this), keccak256(abi.encode(chainId, channel, msgIndex)));
    }

    function changeOwner(address newOwner) external onlyOwner {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function setApproved(address operator, bool approve) external onlyOwner {
        approvedOf[operator] = approve;
        emit SetApproved(operator, approve);
    }

    function isApproved(address operator) public view returns (bool) {
        return approvedOf[operator];
    }

    function withdraw(address to, uint256 amount) external onlyApproved {
        (bool success,) = to.call{value: amount}("");
        require(success, "!withdraw");
        emit Withdrawal(to, amount);
    }

    function setFee(uint256 chainId, uint256 fee_) external onlyApproved {
        feeOf[chainId] = fee_;
        emit SetFee(chainId, fee_);
    }

    function fee(uint256 toChainId, address /*ua*/ ) public view returns (uint256) {
        uint256 f = feeOf[toChainId];
        require(f != 0, "!fee");
        return f;
    }
}
