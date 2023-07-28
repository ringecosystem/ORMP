// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

abstract contract ReentrancyGuard {
    // send and receive nonreentrant lock
    uint8 internal constant _NOT_ENTERED = 1;
    uint8 internal constant _ENTERED = 2;
    uint8 internal _send_state = 1;
    uint8 internal _receive_state = 1;

    modifier sendNonReentrant() {
        require(_send_state == _NOT_ENTERED, "LayerZero: no send reentrancy");
        _send_state = _ENTERED;
        _;
        _send_state = _NOT_ENTERED;
    }

    modifier recvNonReentrant() {
        require(_receive_state == _NOT_ENTERED, "LayerZero: no receive reentrancy");
        _receive_state = _ENTERED;
        _;
        _receive_state = _NOT_ENTERED;
    }
}
