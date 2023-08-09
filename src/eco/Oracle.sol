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

import "../Verifier.sol";
import "../interfaces/IFeedOracle.sol";

contract Oracle is Verifier {
    event Assigned(bytes32 indexed msgHash, uint256 fee);
    event SetFee(uint256 indexed chainId, uint256 fee);
    event SetDapi(uint256 indexed chainId, address dapi);
    event SetApproved(address relayer, bool approve);

    address public immutable ENDPOINT;
    address public owner;

    // chainId => price
    mapping(uint256 => uint256) public feeOf;
    // chainId => dapi
    mapping(uint256 => address) public dapiOf;
    mapping(address => bool) public approvedOf;

    modifier onlyOwner() {
        require(msg.sender == owner, "!owner");
        _;
    }

    modifier onlyApproved() {
        require(isApproved(msg.sender), "!approve");
        _;
    }

    constructor(address endpoint) {
        ENDPOINT = endpoint;
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

    function withdraw(address to, uint256 amount) external onlyApproved {
        (bool success,) = to.call{value: amount}("");
        require(success, "!withdraw");
    }

    function setFee(uint256 chainId, uint256 fee_) external onlyApproved {
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

    function assign(bytes32 msgHash) external payable {
        require(msg.sender == ENDPOINT, "!enpoint");
        emit Assigned(msgHash, msg.value);
    }

    function merkleRoot(uint256 chainId, uint256 /*blockNumber*/) public view override returns (bytes32) {
        address dapi = dapiOf[chainId];
        return IFeedOracle(dapi).messageRoot();
    }
}
