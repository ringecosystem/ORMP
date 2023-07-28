// This file is part of Darwinia.
// Copyright (C) 2018-2022 Darwinia Network
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
import "./call/ExcessivelySafeCall.sol";
import "./interfaces/IUserConfig.sol";
import "./interfaces/IChannel.sol";
import "./interfaces/IRelayer.sol";
import "./interfaces/IOracle.sol";
import "./security/ReentrancyGuard.sol";

contract Endpoint is ReentrancyGuard {
    using ExcessivelySafeCall for address;

    event ClearFailedMessage(bytes32 indexed msgHash);
    event RetryFailedMessage(bytes32 indexed msgHash, bool dispatchResult);

    address public immutable CONFIG;
    address public immutable CHANNEL;

    /// msgHash => failed
    mapping(bytes32 => bool) public fails;

    constructor(address config, address channel) {
        CONFIG = config;
        CHANNEL = channel;
    }

    // https://eips.ethereum.org/EIPS/eip-5750
    function send(uint256 toChainId, address to, bytes calldata encoded, bytes calldata params) external payable sendNonReentrant {
        address ua = msg.sender;
        Config memory uaConfig = IUserConfig(CONFIG).getAppConfig(ua);
        uint256 index = IChannel(CHANNEL).sendMessage(ua, toChainId, to, encoded);

        uint256 relayerFee = _handleRelayer(uaConfig.relayer, index, toChainId, ua, encoded.length, params);
        uint256 oracleFee = _handleOracle(uaConfig.oracle, index, toChainId, ua);

        //refund
        if (msg.value > relayerFee + oracleFee) {
            uint256 refund = msg.value - (relayerFee + oracleFee);
            payable(ua).transfer(refund);
        }
    }

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
        uint256 index,
        uint256 toChainId,
        address ua,
        uint256 size,
        bytes calldata params
    ) internal returns (uint256) {
        uint256 relayerFee = IRelayer(relayer).fee(toChainId, ua, size, params);
        return IRelayer(relayer).assign{value: relayerFee}(index, toChainId, ua, size, params);
    }

    function _handleOracle(address oracle, uint256 index, uint256 toChainId, address ua) internal returns (uint256) {
        uint256 oracleFee = IOracle(oracle).fee(toChainId, ua);
        return IOracle(oracle).assign{value: oracleFee}(index, toChainId, ua);
    }

    function recv(Message calldata message) external recvNonReentrant returns (bool dispatchResult) {
        require(msg.sender == CHANNEL, "!auth");
        dispatchResult = _dispatch(message);
        if (!dispatchResult) {
            bytes32 msgHash = hash(message);
            fails[msgHash] = true;
        }
    }

    /// Retry failed message
    function retryFailedMessage(Message calldata message) external recvNonReentrant returns (bool dispatchResult) {
        bytes32 msgHash = hash(message);
        require(fails[msgHash] == true, "!failed");
        dispatchResult = _dispatch(message);
        if (dispatchResult) {
            delete fails[msgHash];
        }
        emit RetryFailedMessage(msgHash, dispatchResult);
    }

    function clearFailedMessage(Message calldata message) external {
        bytes32 msgHash = hash(message);
        require(fails[msgHash] == true, "!failed");
        require(message.to == msg.sender, "!auth");
        delete fails[msgHash];
        emit ClearFailedMessage(msgHash);
    }

    /// @dev dispatch the cross chain message
    function _dispatch(Message memory message) private returns (bool dispatchResult) {
        // Deliver the message to the target
        (dispatchResult,) = message.to.excessivelySafeCall(
            gasleft(), 0, abi.encodePacked(message.encoded, hash(message), uint256(message.fromChainId), message.from)
        );
    }
}
