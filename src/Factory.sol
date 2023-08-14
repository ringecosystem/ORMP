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

contract Factory {
    event Deployed(bytes32 salt, address config, address channel, address endpoint);

    function deploy(bytes32 salt) external returns (address, address, address) {
        address config = create2(salt, type(UserConfig).creationCode);
        UserConfig(config).changeSetter(msg.sender);

        address channel = create2(salt, type(Channel).creationCode);
        address endpoint = create2(salt, type(Endpoint).creationCode);
        Channel(channel).init(config, endpoint);
        Endpoint(endpoint).init(config, channel);

        require(Channel(channel).CONFIG() == config);
        require(Channel(channel).ENDPOINT() == endpoint);
        require(Endpoint(endpoint).CONFIG() == config);
        require(Endpoint(endpoint).CHANNEL() == channel);

        emit Deployed(salt, config, channel, endpoint);
        return (config, channel, endpoint);
    }

    function create2(bytes32 salt, bytes memory bytecode) internal returns (address addr) {
        assembly {
            addr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "!create2");
    }
}
