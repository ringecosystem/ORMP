// This file is part of Darwinia.
// Copyright (C) 2018-2023 Darwinia Network
// SPDX-License-Identifier: GPL-3.0
//
// Darwinia is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Darwinia is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Darwinia. If not, see <https://www.gnu.org/licenses/>.

pragma solidity 0.8.17;

import "./Common.sol";
import "./interfaces/IOracle.sol";
import "./interfaces/IChannel.sol";
import "./interfaces/IRelayer.sol";
import "./interfaces/IUserConfig.sol";
import "./security/ReentrancyGuard.sol";
import "./security/ExcessivelySafeCall.sol";

/// @title Endpoint
/// @notice An endpoint is a type of network node for cross-chain communication.
/// It is an interface exposed by a communication channel.
/// @dev An endpoint is associated with an immutable channel and user configuration.
contract Endpoint is ReentrancyGuard {
    using ExcessivelySafeCall for address;

    /// msgHash => isFailed
    mapping(bytes32 => bool) public fails;

    /// @dev User config immutable address.
    address public immutable CONFIG;
    /// @dev Channel immutable address.
    address public immutable CHANNEL;

    /// @dev Notifies an observer that the failed message has been cleared.
    /// @param msgHash Hash of the message.
    event ClearFailedMessage(bytes32 indexed msgHash);
    /// @dev Notifies an observer that the failed message has been retried.
    /// @param msgHash Hash of the message.
    /// @param dispatchResult Result of the message dispatch.
    event RetryFailedMessage(bytes32 indexed msgHash, bool dispatchResult);

    /// @dev Init code.
    /// @param config User config immutable address.
    /// @param channel Channel immutable address.
    constructor(address config, address channel) {
        CONFIG = config;
        CHANNEL = channel;
    }

    /// @dev Send a cross-chain message over the endpoint.
    /// @notice follow https://eips.ethereum.org/EIPS/eip-5750
    /// @param toChainId The Message destination chain id.
    /// @param to User application contract address which receive the message.
    /// @param encoded The calldata which encoded by ABI Encoding.
    /// @param params General extensibility for relayer to custom functionality.
    function send(uint256 toChainId, address to, bytes calldata encoded, bytes calldata params)
        external
        payable
        sendNonReentrant
        returns (bytes32)
    {
        // user application address.
        address ua = msg.sender;
        // fetch user application's config.
        Config memory uaConfig = IUserConfig(CONFIG).getAppConfig(ua);
        // send message by channel, return the hash of the message as id.
        bytes32 msgHash = IChannel(CHANNEL).sendMessage(ua, toChainId, to, encoded);

        // handle relayer fee
        uint256 relayerFee = _handleRelayer(uaConfig.relayer, msgHash, toChainId, ua, encoded.length, params);
        // handle oracle fee
        uint256 oracleFee = _handleOracle(uaConfig.oracle, msgHash, toChainId, ua);

        //refund
        if (msg.value > relayerFee + oracleFee) {
            uint256 refund = msg.value - (relayerFee + oracleFee);
            (bool success,) = ua.call{value: refund}("");
            require(success, "!refund");
        }

        return msgHash;
    }

    /// @notice Get a quote in source native gas, for the amount that send() requires to pay for message delivery.
    /// @param toChainId The Message destination chain id.
    //  @param to User application contract address which receive the message.
    /// @param encoded The calldata which encoded by ABI Encoding.
    /// @param params General extensibility for relayer to custom functionality.
    function fee(uint256 toChainId, address, /*to*/ bytes calldata encoded, bytes calldata params)
        external
        view
        returns (uint256)
    {
        address ua = msg.sender;
        Config memory uaConfig = IUserConfig(CONFIG).getAppConfig(ua);
        uint256 relayerFee = IRelayer(uaConfig.relayer).fee(toChainId, ua, encoded.length, params);
        uint256 oracleFee = IOracle(uaConfig.oracle).fee(toChainId, ua);
        return relayerFee + oracleFee;
    }

    function _handleRelayer(
        address relayer,
        bytes32 msgHash,
        uint256 toChainId,
        address ua,
        uint256 size,
        bytes calldata params
    ) internal returns (uint256) {
        uint256 relayerFee = IRelayer(relayer).fee(toChainId, ua, size, params);
        return IRelayer(relayer).assign{value: relayerFee}(msgHash, toChainId, ua, size, params);
    }

    function _handleOracle(address oracle, bytes32 msgHash, uint256 toChainId, address ua) internal returns (uint256) {
        uint256 oracleFee = IOracle(oracle).fee(toChainId, ua);
        return IOracle(oracle).assign{value: oracleFee}(msgHash, toChainId, ua);
    }

    /// @dev Recv verified message from Channel and dispatch to destination user application address.
    /// @notice Only channel could call this function.
    /// @param message Verified receive message info.
    /// @return dispatchResult Result of the message dispatch.
    function recv(Message calldata message) external recvNonReentrant returns (bool dispatchResult) {
        require(msg.sender == CHANNEL, "!auth");
        bytes32 msgHash = hash(message);
        dispatchResult = _dispatch(message, msgHash);
        if (!dispatchResult) {
            fails[msgHash] = true;
        }
    }

    /// @dev Retry failed message.
    /// @param message Failed message info.
    /// @return dispatchResult Result of the message dispatch.
    function retryFailedMessage(Message calldata message) external recvNonReentrant returns (bool dispatchResult) {
        bytes32 msgHash = hash(message);
        require(fails[msgHash] == true, "!failed");
        dispatchResult = _dispatch(message, msgHash);
        if (dispatchResult) {
            delete fails[msgHash];
        }
        emit RetryFailedMessage(msgHash, dispatchResult);
    }

    /// @dev Retry failed message.
    /// @notice Only message.to could clear this message.
    /// @param message Failed message info.
    function clearFailedMessage(Message calldata message) external {
        bytes32 msgHash = hash(message);
        require(fails[msgHash] == true, "!failed");
        require(message.to == msg.sender, "!auth");
        delete fails[msgHash];
        emit ClearFailedMessage(msgHash);
    }

    /// @dev Dispatch the cross chain message.
    function _dispatch(Message memory message, bytes32 msgHash) private returns (bool dispatchResult) {
        // Deliver the message to user application contract address.
        (dispatchResult,) = message.to.excessivelySafeCall(
            gasleft(), 0, abi.encodePacked(message.encoded, msgHash, uint256(message.fromChainId), message.from)
        );
    }
}
