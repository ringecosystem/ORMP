// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./AppBase.sol";

abstract contract Application is AppBase {
    address public immutable ORMP;

    modifier onlyORMP() override {
        require(ORMP == msg.sender, "!ormp");
        _;
    }

    constructor(address ormp) {
        ORMP = ormp;
    }

    function _setAppConfig(address oracle, address relayer) internal virtual {
        IORMP(ORMP).setAppConfig(oracle, relayer);
    }
}
