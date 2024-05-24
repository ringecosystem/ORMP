// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./UserConfig.sol";
import "./interfaces/IVerifier.sol";

/// @title Channel
/// @notice A channel is a logical connection over cross-chain network.
/// It used for cross-chain message transfer.
/// - Accepts messages to be dispatched to destination chains,
///   constructs a Merkle tree of the messages.
/// - Dispatches verified messages from source chains.
contract Channel is UserConfig {
    /// @dev msgHash => isDispathed.
    mapping(bytes32 => bool) public dones;

    /// @dev message count.
    uint256 public count;

    /// @dev Self contract address cache.
    address private immutable __self = address(this);

    /// @dev Notifies an observer that the message has been accepted.
    /// @param msgHash Hash of the message.
    /// @param message Accepted message info.
    event MessageAccepted(bytes32 indexed msgHash, Message message);
    /// @dev Notifies an observer that the message has been dispatched.
    /// @param msgHash Hash of the message.
    /// @param dispatchResult The message dispatch result.
    event MessageDispatched(bytes32 indexed msgHash, bool dispatchResult);

    /// @dev Init code.
    constructor(address dao) UserConfig(dao) {}

    /// @dev Fetch local chain id.
    /// @return chainId Local chain id.
    function LOCAL_CHAINID() public view returns (uint256) {
        return block.chainid;
    }

    /// @dev Send message.
    /// @param from User application contract address which send the message.
    /// @param toChainId The Message destination chain id.
    /// @param to User application contract address which receive the message.
    /// @param gasLimit Gas limit for destination user application used.
    /// @param encoded The calldata which encoded by ABI Encoding.
    function _send(address from, uint256 toChainId, address to, uint256 gasLimit, bytes calldata encoded)
        internal
        returns (bytes32)
    {
        // only cross-chain message
        require(toChainId != LOCAL_CHAINID(), "!cross-chain");
        // constuct message object.
        Message memory message = Message({
            channel: __self,
            index: count,
            fromChainId: LOCAL_CHAINID(),
            from: from,
            toChainId: toChainId,
            to: to,
            gasLimit: gasLimit,
            encoded: encoded
        });
        // hash the message.
        bytes32 msgHash = hash(message);

        // emit accepted message event.
        emit MessageAccepted(msgHash, message);

        // increase message count
        count = count + 1;

        // return this message hash.
        return msgHash;
    }

    /// @dev Receive messages.
    /// @notice Only message.to's config relayer could relay this message.
    /// @param message Received message info.
    /// @param proof Message proof of this message.
    function _recv(Message calldata message, bytes calldata proof) internal returns (bytes32) {
        // get message.to user config.
        UC memory uc = getAppConfig(message.to);
        // only the config relayer could relay this message.
        require(uc.relayer == msg.sender, "!auth");
        // verify message by the config oracle.
        require(IVerifier(uc.oracle).verifyMessageProof(message, proof), "!proof");
        // check destination chain id is correct.
        require(LOCAL_CHAINID() == message.toChainId, "!toChainId");
        // hash the message.
        bytes32 msgHash = hash(message);
        // check the message is not dispatched.
        require(dones[msgHash] == false, "done");

        // set the message is dispatched.
        dones[msgHash] = true;

        return msgHash;
    }
}
