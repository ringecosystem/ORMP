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

contract Relayer {
    event Assigned(uint32 indexed index, uint fee);
    event SetPrice(uint32 indexed chainId, uint64 baseGas, uint64 gasPerByte);

    struct Price {
        uint64 baseGas; // gas in source chain = 200000 gas in target chain
        uint64 gasPerByte;
    }

    address public immutable ENDPOINT;
    address public owner;

    // chainId => price
    mapping(uint32 => Price) public priceOf;

    modifier onlyOwner {
        require(msg.sender == owner, "!owner");
        _;
    }

    constructor(address endpoint) {
        ENDPOINT = endpoint;
        owner = msg.sender;
    }

    receive() external payable {}

    function setPrice(uint32 chainId, uint64 baseGas, uint64 gasPerByte) external onlyOwner {
        priceOf[chainId] = Price(baseGas, gasPerByte);
        emit SetPrice(chainId, baseGas, gasPerByte);
    }

    function withdraw(uint amount) external onlyOwner {
        payable(owner).transfer(amount);
    }

    // params = [extraGas]
    function fee(uint32 toChainId, address ua, uint size, bytes calldata params) public view returns (uint) {
        uint extraGas = abi.decode(params, (uint));
        Price memory p = priceOf[toChainId];
        uint gas = p.baseGas + extraGas * p.baseGas / 200000;
        return gas + p.gasPerByte * size;
    }

    function assign(uint32 index, uint32 toChainId, address ua, uint size, bytes calldata params) external payable returns (uint) {
        require(msg.sender == ENDPOINT, "!enpoint");
        uint totalFee = fee(toChainId, ua, size, params);
        require(msg.value == totalFee, "!fee");
        emit Assigned(index, totalFee);
        return totalFee;
    }
}
