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

import "../interfaces/IFeedOracle.sol";
import "../Verifier.sol";

contract Oracle is Verifier {
    event Assigned(bytes32 indexed msgHash);
    event SetFee(uint256 indexed chainId, uint256 fee);
    event SetDapi(uint256 indexed chainId, address dapi);

    address public immutable ENDPOINT;
    address public owner;

    // chainId => price
    mapping(uint256 => uint256) public feeOf;
    // chainId => dapi
    mapping(uint256 => address) public dapiOf;

    modifier onlyOwner() {
        require(msg.sender == owner, "!owner");
        _;
    }

    constructor(address endpoint) {
        ENDPOINT = endpoint;
        owner = msg.sender;
    }

    receive() external payable {}

    function changeOwner(address owner_) external onlyOwner {
        owner = owner_;
    }

    function withdraw(uint256 amount) external onlyOwner {
        payable(owner).transfer(amount);
    }

    function setFee(uint256 chainId, uint256 fee_) external onlyOwner {
        feeOf[chainId] = fee_;
        emit SetFee(chainId, fee_);
    }

    function setDapi(uint256 chainId, address dapi) external onlyOwner {
        dapiOf[chainId] = dapi;
        emit SetDapi(chainId, dapi);
    }

    function fee(uint256 toChainId, address /*ua*/ ) public view returns (uint256) {
        return feeOf[toChainId];
    }

    function assign(bytes32 msgHash, uint256 toChainId, address /*ua*/ ) external payable returns (uint256) {
        require(msg.sender == ENDPOINT, "!enpoint");
        uint256 totalFee = feeOf[toChainId];
        require(msg.value == totalFee, "!fee");
        emit Assigned(msgHash);
        return totalFee;
    }

    function merkleRoot(uint256 chainId) public view override returns (bytes32) {
        address dapi = dapiOf[chainId];
        (, bytes32 msgRoot) = IFeedOracle(dapi).latestAnswer();
        return msgRoot;
    }
}
