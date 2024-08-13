// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

/// I want to use this contract to test merkle trees for creator sign-up on the protocol

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Draft is Ownable {
    error Draft__InvalidProof();
    error Draft__AlreadyACreator();

    address[] listOfApproved; // list of addresses that have been approved to be creators
    address[] listOfCreators; // list of creators

    bytes32 private immutable i_merkleRoot;
    uint256 private s_creatorCount;
    address private s_admin;

    mapping(address => bool) private s_hasBecomeCreator;

    event CreatorSuccessful(address indexed adressThatBecameCreator, address indexed whoCalledTheFunction);

    modifier notACreator(address intendingCreator) {
        if (s_hasBecomeCreator[intendingCreator]) {
            revert Draft__AlreadyACreator();
        }
        _;
    }

    constructor(bytes32 merkleRoot) Ownable(msg.sender) {
        i_merkleRoot = merkleRoot;
        s_admin = msg.sender;
        s_creatorCount = 0;
    }

    function becomeCreator(address intendingCreator, bytes32[] calldata merkleProof)
        external
        notACreator(intendingCreator)
    {
        require(intendingCreator != address(0), "");

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(intendingCreator))));

        if (MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert Draft__InvalidProof();
        }

        listOfCreators.push(intendingCreator);
        s_hasBecomeCreator[intendingCreator] = true;

        emit CreatorSuccessful(intendingCreator, msg.sender);

        s_creatorCount++;
    }

    function setAdmin(address newAdmin) external onlyOwner {
        s_admin = newAdmin;
    }

    // >>---------------------->> helper functions

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getCreatorCount() external view returns(uint256) {
        return s_creatorCount;
    }

    function getAdmin() external view returns(address) {
        return s_admin;
    }
}
