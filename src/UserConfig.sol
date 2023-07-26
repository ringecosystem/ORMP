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

import "./interfaces/IUserConfig.sol";

contract UserConfig {
    event SetDefaultConfig(address relayer, address oracle);
    event AppConfigUpdated(address indexed ua, address relayer, address oracle);

    // ua => config
    mapping(address => Config) public appConfig;
    // default UA settings if no version specified
    Config public defaultAppConfig;
    address public setter;

    modifier onlySetter {
        require(msg.sender == setter, "!auth");
        _;
    }

    function changeSetter(address _setter) external onlySetter {
        setter = _setter;
    }

    constructor() {
        setter = msg.sender;
    }

    function setDefaultConfig(address relayer, address oracle) external onlySetter {
        defaultAppConfig = Config(relayer, oracle);
        emit SetDefaultConfig(relayer, oracle);
    }

    // default to DEFAULT setting if ZERO value
    function getAppConfig(address ua) external view returns (Config memory) {
        Config memory c = appConfig[ua];
        Config memory defaultConfig = defaultAppConfig;

        if (c.relayer == address(0x0)) {
            c.relayer = defaultConfig.relayer;
        }

        if (c.oracle == address(0x0)) {
            c.oracle = defaultConfig.oracle;
        }

        return c;
    }

    function setAppConfig(address relayer, address oracle) external {
        appConfig[msg.sender] = Config(relayer, oracle);
        emit AppConfigUpdated(msg.sender, relayer, oracle);
    }
}
