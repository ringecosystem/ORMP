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

/// @title UserConfig
/// @notice User config could select their own relayer and oracle.
/// The default configuration is used by default.
/// @dev Only setter could set default config.
contract UserConfig {
    /// @dev Notifies an observer that the default config has set.
    /// @param relayer Default relayer.
    /// @param oracle Default oracle.
    event SetDefaultConfig(address relayer, address oracle);
    /// @dev Notifies an observer that the user application config has updated.
    /// @param ua User application contract address.
    /// @param relayer Relayer which user application choose.
    /// @param oracle Oracle which user application.
    event AppConfigUpdated(address indexed ua, address relayer, address oracle);

    /// @dev ua => config.
    mapping(address => Config) public appConfig;
    /// @dev Default config.
    Config public defaultConfig;
    /// @dev Setter address.
    address public setter;

    modifier onlySetter() {
        require(msg.sender == setter, "!auth");
        _;
    }

    /// @dev Change setter.
    /// @notice Only current setter could call.
    /// @param setter_ New setter.
    function changeSetter(address setter_) external onlySetter {
        setter = setter_;
    }

    constructor() {
        setter = msg.sender;
    }

    /// @dev Set default config for all application.
    /// @notice Only setter could call.
    /// @param relayer Default relayer.
    /// @param oracle Default oracle.
    function setDefaultConfig(address relayer, address oracle) external onlySetter {
        defaultConfig = Config(relayer, oracle);
        emit SetDefaultConfig(relayer, oracle);
    }

    /// @dev Fetch user application config.
    /// @notice If user application has not configured, then the default config is used.
    /// @param ua User application contract address.
    /// @return user application config.
    function getAppConfig(address ua) external view returns (Config memory) {
        Config memory c = appConfig[ua];

        if (c.relayer == address(0x0)) {
            c.relayer = defaultConfig.relayer;
        }

        if (c.oracle == address(0x0)) {
            c.oracle = defaultConfig.oracle;
        }

        return c;
    }

    /// @notice Set user application config.
    /// @param relayer Relayer which user application choose.
    /// @param oracle Oracle which user application.
    function setAppConfig(address relayer, address oracle) external {
        appConfig[msg.sender] = Config(relayer, oracle);
        emit AppConfigUpdated(msg.sender, relayer, oracle);
    }
}
