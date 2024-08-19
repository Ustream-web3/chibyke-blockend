// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

/// I want to use this contract to test merkle trees for creator sign-up on the protocol

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Creator Contract for UStream Project
 * @author Chukwubuike Victory Chime
 * @notice This contract allows verified creators to sign up for the UStream platform after completing an off-chain form and verification process.
 * @dev The contract uses Merkle trees to verify that an address is allowed to become a creator.
 */
contract Creator is Ownable {
    // >>--------------------->> ERRORS
    ///@dev Thrown when the provided Merkle proof is invalid
    error Creator__InvalidProof();
    ///@dev Thrown when an address that has already become a creator attempts to registr again
    error Creator__AlreadyACreator();

    // >>--------------------->> VARIABLES
    ///@dev Array of addresses that have been approved to be creators
    // address[] listOfApproved; // ---> @note There should be no need for this since I am using Merkle proofs
    ///@dev Array of addresses that have successfully become creators
    address[] listOfCreators;

    ///@dev The Merkle root used to verify the legitimacy of creator sign-ups
    bytes32 private immutable i_merkleRoot;
    ///@dev The total number of creators registered on the platform
    uint256 private s_creatorCount;
    ///@dev The address of the current admin who has special privileges within the platform
    address private s_admin;

    ///@dev A mapping that tracks whether an address has already become a creator
    mapping(address => bool) private s_hasBecomeCreator;

    // >>--------------------->> EVENTS
    /**
     * @notice Emitted when an address successfully becomes a creator
     * @param adressThatBecameCreator The address that was added as a creator
     * @param whoAddedCreator The address that initiated the creator addition
     */
    event CreatorSuccessful(address indexed adressThatBecameCreator, address indexed whoAddedCreator);

    // >>--------------------->> MODIFIERS
    /**
     * @notice Ensures that an address has not already become a creator
     * @param intendingCreator The address attempting to register as a creator
     */
    modifier notACreator(address intendingCreator) {
        if (s_hasBecomeCreator[intendingCreator]) {
            revert Creator__AlreadyACreator();
        }
        _;
    }

    // >>--------------------->> CONSTRUCTOR
    constructor(bytes32 merkleRoot) Ownable(msg.sender) {
        i_merkleRoot = merkleRoot;
        s_admin = msg.sender;
        s_creatorCount = 0;
    }

    // >>--------------------->> EXTERNAL FUNCTIONS
    /**
     * @notice Allows an approved address to become a creator on the platform
     * @param intendingCreator The address attempting to register as a creator
     * @param merkleProof The Merkle proof corresponding to the address
     * @custom:error Creator__InvalidProof Thrown if the provided Merkle proof is invalid
     * @custom:error Creator__AlreadyACreator Thrown if the address has already become a creator
     * @dev The reason why the `msg.sender` of this function is emitted in the event is because there might be a need to track who added a particular creator. Plus, there might be a future update where only Admin(s) can add creators to the platform
     */
    function becomeCreator(address intendingCreator, bytes32[] calldata merkleProof)
        external
        notACreator(intendingCreator)
    {
        require(intendingCreator != address(0), "");

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(intendingCreator))));

        if (MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert Creator__InvalidProof();
        }

        listOfCreators.push(intendingCreator);
        s_hasBecomeCreator[intendingCreator] = true;

        emit CreatorSuccessful(intendingCreator, msg.sender);

        s_creatorCount++;
    }

    /**
     * @notice Allows the owner to set a new admin for the platform
     * @param newAdmin The address of the new admin
     */
    function setAdmin(address newAdmin) external onlyOwner {
        s_admin = newAdmin;
    }

    // >>---------------------->> GETTER FUNCTIONS
    /**
     * @notice Returns the current Merkle root used for verifying creators
     * @return The Merkle root
     */
    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    /**
     * @notice Returns the total number of creators registered on the platform
     * @return The number of creators
     */
    function getCreatorCount() external view returns (uint256) {
        return s_creatorCount;
    }

    /**
     * @notice Returns the current admin address
     * @return The admin address
     */
    function getAdmin() external view returns (address) {
        return s_admin;
    }
}
