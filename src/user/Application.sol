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

import "../Common.sol";
import "../interfaces/IEndpoint.sol";

// https://eips.ethereum.org/EIPS/eip-5164
abstract contract Application {
    address public immutable TRUSTED_ORMP;

    constructor(address ormp) {
        TRUSTED_ORMP = ormp;
    }

    function _clearFailedMessage(Message calldata message) internal virtual {
        return IEndpoint(TRUSTED_ORMP).clearFailedMessage(message);
    }

    function retryFailedMessage(Message calldata message) public virtual returns (bool dispatchResult) {
        return IEndpoint(TRUSTED_ORMP).retryFailedMessage(message);
    }

    function setAppConfig(address oracle, address relayer) public virtual {
        IEndpoint(TRUSTED_ORMP).setAppConfig(oracle, relayer);
    }

    function isTrustedORMP(address ormp) public view returns (bool) {
        return TRUSTED_ORMP == ormp;
    }

    function _messageId() internal pure returns (bytes32 _msgDataMessageId) {
        require(msg.data.length >= 84, "!messageId");
        assembly {
            _msgDataMessageId := calldataload(sub(calldatasize(), 84))
        }
    }

    function _fromChainId() internal pure returns (uint256 _msgDataFromChainId) {
        require(msg.data.length >= 52, "!fromChainId");
        assembly {
            _msgDataFromChainId := calldataload(sub(calldatasize(), 52))
        }
    }

    function _xmsgSender() internal view returns (address payable _from) {
        require(msg.data.length >= 20 && isTrustedORMP(msg.sender), "!xmsgSender");
        assembly {
            _from := shr(96, calldataload(sub(calldatasize(), 20)))
        }
    }
}
