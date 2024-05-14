// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../interfaces/IORMP.sol";

// https://eips.ethereum.org/EIPS/eip-5164
abstract contract AppBase {
    modifier onlyORMP() virtual {
        _;
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

    function _xmsgSender() internal pure returns (address payable _from) {
        require(msg.data.length >= 20, "!xmsgSender");
        assembly {
            _from := shr(96, calldataload(sub(calldatasize(), 20)))
        }
    }
}
