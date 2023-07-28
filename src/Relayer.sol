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

import "./Common.sol";

interface IChannel {
    function recvMessage(Message calldata message, bytes calldata proof) external;
}

contract Relayer {
    event Assigned(bytes32 indexed msgHash, uint256 fee);
    event SetPrice(uint32 indexed chainId, uint64 benchGas, uint64 baseGas, uint64 gasPerByte);
    event SetApproved(address relayer, bool approve);

    struct Price {
        uint64 benchGas; // merkle proof bench gas in targe chain
        uint64 baseGas; // gas in source chain related to bench gas in target chain
        uint64 gasPerByte; // gas per byte in source chain
    }

    address public immutable ENDPOINT;
    address public immutable CHANNEL;
    address public owner;

    // chainId => price
    mapping(uint32 => Price) public priceOf;
    mapping(address => bool) public approvedOf;

    modifier onlyOwner() {
        require(msg.sender == owner, "!owner");
        _;
    }

    modifier onlyApproved() {
        require(isApproved(msg.sender), "!approve");
        _;
    }

    constructor(address endpoint, address channel) {
        ENDPOINT = endpoint;
        CHANNEL = channel;
        owner = msg.sender;
        setApproved(msg.sender, true);
    }

    receive() external payable {}

    function changeOwner(address owner_) external onlyOwner {
        owner = owner_;
    }

    function isApproved(address relayer) public view returns (bool) {
        return approvedOf[relayer];
    }

    function setApproved(address relayer, bool approve) public onlyOwner {
        approvedOf[relayer] = approve;
        emit SetApproved(relayer, approve);
    }

    function setPrice(uint32 chainId, uint64 benchGas, uint64 baseGas, uint64 gasPerByte) external onlyApproved {
        priceOf[chainId] = Price(benchGas, baseGas, gasPerByte);
        emit SetPrice(chainId, benchGas, baseGas, gasPerByte);
    }

    function withdraw(address to, uint256 amount) external onlyApproved {
        payable(to).transfer(amount);
    }

    // params = [extraGas]
    function fee(uint32 toChainId, address, /*ua*/ uint256 size, bytes calldata params) public view returns (uint256) {
        uint256 extraGas = abi.decode(params, (uint256));
        Price memory p = priceOf[toChainId];
        uint256 gas = p.baseGas + extraGas * p.baseGas / p.benchGas;
        return gas + p.gasPerByte * size;
    }

    function assign(bytes32 msgHash, uint32 toChainId, address ua, uint256 size, bytes calldata params)
        external
        payable
        returns (uint256)
    {
        require(msg.sender == ENDPOINT, "!enpoint");
        uint256 totalFee = fee(toChainId, ua, size, params);
        require(msg.value == totalFee, "!fee");
        emit Assigned(msgHash, totalFee);
        return totalFee;
    }

    function relay(Message calldata message, bytes calldata proof) external onlyApproved {
        IChannel(CHANNEL).recvMessage(message, proof);
    }
}
