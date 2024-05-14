// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./IVerifier.sol";

interface IOracle is IVerifier {
    /// @notice Fetch oracle price to relay message root to the destination chain.
    /// @param toChainId The destination chain id.
    /// @param ua The user application which send the message.
    /// @return Oracle price in source native gas.
    function fee(uint256 toChainId, address ua) external view returns (uint256);
}
