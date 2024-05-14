// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../Common.sol";

interface IVerifier {
    /// @notice Verify message proof
    /// @dev Message proof provided by relayer. Oracle should provide message root of
    ///      source chain, and verify the merkle proof of the message hash.
    /// @param message The message info.
    /// @param proof Proof of the message
    /// @return Result of the message verify.
    function verifyMessageProof(Message calldata message, bytes calldata proof) external view returns (bool);
}
