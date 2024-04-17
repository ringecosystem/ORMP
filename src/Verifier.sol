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

import "./interfaces/IVerifier.sol";

abstract contract Verifier is IVerifier {
    /// @notice Message proof.
    /// @param msgIndex The index of the message hash.
    struct Proof {
        uint256 msgIndex;
    }

    /// @inheritdoc IVerifier
    function merkleRoot(uint256 chainId, uint256 msgIndex) public view virtual returns (bytes32);

    /// @inheritdoc IVerifier
    function verifyMessageProof(uint256 fromChainId, bytes32 msgHashRelayer, bytes calldata proof)
        external
        view
        returns (bool)
    {
        // decode proof
        Proof memory p = abi.decode(proof, (Proof));

        // fetch message hash from chain
        bytes32 msgHashOracle = merkleRoot(fromChainId, p.msgIndex);

        // check oracle's message hash equal relayer's message hash
        return msgHashOracle == msgHashRelayer;
    }
}
