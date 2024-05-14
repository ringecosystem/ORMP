// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./interfaces/IVerifier.sol";

abstract contract Verifier is IVerifier {
    /// @notice Fetch message hash.
    /// @param chainId The source chain id.
    /// @param channel The message channel.
    /// @param msgIndex The Message index.
    /// @return Message hash in source chain.
    function hashOf(uint256 chainId, address channel, uint256 msgIndex) public view virtual returns (bytes32);

    /// @inheritdoc IVerifier
    function verifyMessageProof(Message calldata message, bytes calldata) external view returns (bool) {
        // check oracle's message hash equal relayer's message hash
        return hashOf(message.fromChainId, message.channel, message.index) == hash(message);
    }
}
