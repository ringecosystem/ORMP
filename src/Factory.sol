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

import "./UserConfig.sol";
import "./Endpoint.sol";
import "./Channel.sol";

import "./eco/Oracle.sol";
import "./eco/Relayer.sol";

contract Factory {
    event Deployed(address config, address channel, address endpoint);
    bytes32 public immutable SALT;
    address public immutable DEPLOYER;

    UserConfig public config;
    Channel public channel;
    Endpoint public endpoint;

    constructor(address deployer, bytes32 salt) {
        SALT = salt;
        DEPLOYER = deployer;
    }

    function deploy() external returns (address, address, address) {
        require(msg.sender == DEPLOYER, "!deployer");

        config = new UserConfig{salt: SALT}();
        config.changeSetter(DEPLOYER);

        channel = new Channel{salt: SALT}();
        endpoint = new Endpoint{salt: SALT}();
        channel.init(address(config), address(endpoint));
        endpoint.init(address(config), address(channel));

        require(channel.CONFIG() == address(config));
        require(channel.ENDPOINT() == address(endpoint));
        require(endpoint.CONFIG() == address(config));
        require(endpoint.CHANNEL() == address(channel));

        emit Deployed(address(config), address(channel), address(endpoint));
        return (address(config), address(channel), address(endpoint));
    }
}
