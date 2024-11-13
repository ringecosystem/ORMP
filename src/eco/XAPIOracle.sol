// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../Verifier.sol";
import "../interfaces/IORMP.sol";
import {IXAPI, IXAPIConsumer, ResponseData} from "./interfaces/IXAPIConsumer.sol";

contract XAPIOracle is Verifier, IXAPIConsumer {
    event SetFee(uint256 indexed chainId, uint256 fee);
    event SetApproved(address operator, bool approve);
    event Withdrawal(address indexed to, uint256 amt);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
	event XAPIRequestMade(uint256 indexed requestId, address exAggregator, string requestData);
    event XAPIConsumeResult(uint256 indexed requestId, bytes responseData, uint16 errorCode);
    event XAPIConsumeError(uint256 indexed requestId, uint16 errorCode);

    address public immutable PROTOCOL;
	address public immutable XAPI;

    address public owner;
    // chainId => price
    mapping(uint256 => uint256) public feeOf;
    // operator => isApproved
    mapping(address => bool) public approvedOf;

	struct XAPIRequst {
		uint256 chainId;
		uint256 msgIndex;
		address channel;
		bool flag;
	}
	mapping(uint => XAPIRequst) public requests;
	uint requestedId;

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

    constructor(address dao, address ormp, address xapi) {
        PROTOCOL = ormp;
        owner = dao;
		XAPI = xapi;
    }

    receive() external payable {}

    function version() public pure returns (string memory) {
        return "2.1.0";
    }

    /// @dev Only could be called by approved address.
	/// @param exAggregator The aggregator extend address on evm.
	/// @param request The XAPI request for specific message.
    /// 1. chainId The source chain id.
    /// 2. channel The message channel.
    /// 3. msgIndex The source chain message index.
	function makeRequestForMessageHash(address exAggregator, string calldata request)
		external
		payable
		onlyApproved
	{
		uint256 fee = IXAPI(XAPI).fee(exAggregator);	
		require(msg.value >= fee, "!fee");
        uint requestId = IXAPI(XAPI).makeRequest{value: fee}(exAggregator, request, this.xapiCallback.selector);
		requires = XAPIRequst({
			chainId;
			msgIndex;
			channel;
			flag;
		});

        emit RequestSent(requestedId, exAggregator, request);
	}


    function xapiCallback(uint256 requestId, ResponseData memory response) external {
    function importMessageHash(uint256 chainId, address channel, uint256 msgIndex, bytes32 msgHash)
        external
        onlyXAPI
    {
		require(requestedId == requestId, "requestId");
        if (response.errorCode != 0) {
			
        	IORMP(PROTOCOL).importHash(chainId, channel, msgIndex, msgHash);
            emit ConsumeResult(requestId, response.result, response.errorCode);
        } else {
            emit ConsumeError(requestId, response.errorCode);
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
