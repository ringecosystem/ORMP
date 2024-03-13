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

pragma solidity ^0.8.17;

import "../interfaces/IORMP.sol";
import "./AppBase.sol";

abstract contract UpgradeableApplication is AppBase {
    address private _ormp;

    event SetORMP(address ormp);

    constructor(address ormp) {
        _ormp = ormp;
    }

    function protocol() public view virtual override returns (address) {
        return _ormp;
    }

    function _setORMP(address ormp) internal virtual {
        _ormp = ormp;
        emit SetORMP(ormp);
    }

    function _setAppConfig(address oracle, address relayer) internal virtual {
        IORMP(protocol()).setAppConfig(oracle, relayer);
    }
}
