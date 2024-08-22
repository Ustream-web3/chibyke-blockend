// SPDX-License-Identifier: SEE LICENSE IN LICENSE

pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @author Chukwubuike Victory Chime
 * @title CreatorRegistry
 * @notice This contract manages a registry of creators, allowing an admin to add, suspend, or remove creators.
 * @notice The contract maintains lists of active, suspended, and removed creators with optimized array management.
 */
contract CreatorRegistry is Ownable {
    // >---------------------------> ERRORS
    /// @dev thrown when the caller is not the admin
    error CreatorRegistry__NotTheAdmin();
    /// @dev thrown when trying to add a creator that already exists
    error CreatorRegistry__CreatorExists();
    /// @dev thrown when trying to interact with a creator that does not exist
    error CreatorRegistry__CreatorDoesNotExist();
    /// @dev thrown when trying to suspend a creator that is already suspended
    error CreatorRegistry__CreatorAlreadySuspended();
    /// @dev thrown when trying to remove a creator that is already removed
    error CreatorRegistry__CreatorAlreadyRemoved();
    /// @dev thrown when an invalid state transition is attempted for a creator
    error CreatorRegistry__InvalidStateTransition();

    // >---------------------------> TYPES
    ///@notice & @dev enum representing the possible states of a creator
    enum CreatorState {
        None, // the creator does not exist
        Active, // the creator is active
        Suspended, // the creator is suspended
        Removed // the creator is removed from the platfomr

    }

    // >---------------------------> STATE VARIABLES
    /// @notice & @dev the admin address responsible for managing creators
    address private s_admin;

    /// @dev mapping of a creator address to their current CreatorState
    mapping(address => CreatorState) private s_creatorState;

    /// @dev list of active creator addresses
    address[] private s_creatorList;
    /// @dev list of suspended creator addresses
    address[] private s_suspendedCreatorList;
    /// @dev list of removed creator addresses
    address[] private s_removedCreatorList;

    /// @dev mapping of a creator address to their index in s_creatorList array
    mapping(address => uint256) private s_creatorIndex;
    /// @dev mapping of a suspended creator to their index in a s_suspendedCreatorList array
    mapping(address => uint256) private s_suspendedCreatorIndex;
    /// @dev mapping of a removed creator to their index in a s_removedCreatorList array
    mapping(address => uint256) private s_removedCreatorIndex;

    /// @dev number of creators in the registry
    uint256 private s_creatorCount;
    /// @dev number of suspended creators in the registry
    uint256 private s_suspendedCreatorCount;
    /// @dev number of removed creators in the registry
    uint256 private s_removedCreatorCount;

    // >---------------------------> EVENTS
    /// @notice emitted when a new creator is added to the registry
    /// @param creator address of the added creator
    /// @param adminThatAddedCreator address of the admin who added the creator
    event CreatorAdded(address indexed creator, address indexed adminThatAddedCreator);
    /// @notice emitted when a creator is suspended from the registry
    /// @param creator address of the suspended creator
    /// @param adminThatSuspendedCreator address of the admin who suspended the creator
    event CreatorSuspended(address indexed creator, address indexed adminThatSuspendedCreator);
    /// @notice emitted when a creator is removed from the registry
    /// @param creator address of the removed creator
    /// @param adminThatRemovedCreator address of the admin who removed the creator
    event CreatorRemoved(address indexed creator, address indexed adminThatRemovedCreator);

    // >---------------------------> MODIFIERS
    /**
     * @dev ensures that the creator is in the expected state before proceeding
     * @param creator address of the creator
     * @param expectedState state the creator should be in
     */
    modifier inState(address creator, CreatorState expectedState) {
        if (s_creatorState[creator] != expectedState) {
            revert CreatorRegistry__InvalidStateTransition();
        }
        _;
    }

    /// @dev ensures only admin can call the function
    modifier onlyAdmin() {
        if (msg.sender != s_admin) {
            revert CreatorRegistry__NotTheAdmin();
        }
        _;
    }

    // >---------------------------> CONSTRUCTOR
    constructor() Ownable(msg.sender) {
        s_admin = msg.sender;
        s_creatorCount = 0;
        s_suspendedCreatorCount = 0;
        s_removedCreatorCount = 0;
    }

    // >---------------------------> EXTERNAL FUNCTIONS
    /**
     * @dev & @notice adds a new creator to the registry
     * @param applicant address of the creator to be added
     * @dev applicant must not already be a creator, so must be in the `None` state
     * @dev can only be called by the admin
     */
    function addCreator(address applicant) external onlyAdmin inState(applicant, CreatorState.None) {
        // mark as Creator
        s_creatorState[applicant] = CreatorState.Active;

        // add to creator list and track index
        s_creatorList.push(applicant);
        s_creatorIndex[applicant] = s_creatorList.length - 1;

        // increase Creator count
        s_creatorCount++;

        // emit event to effect
        emit CreatorAdded(applicant, msg.sender);
    }

    /**
     * @dev & @notice suspends an active creator in the registry
     * @param creator the address of the creator to be suspended
     * @dev address must be in the `Active` state
     * @dev can only be called by the admin
     */
    function suspendCreator(address creator) external onlyAdmin inState(creator, CreatorState.Active) {
        // mark as suspended Creator
        s_creatorState[creator] = CreatorState.Suspended;

        // remove from creator list
        _removeFromArray(s_creatorList, s_creatorIndex, creator);

        // decrease Creator count
        s_creatorCount--;

        // add to suspended creator list and track index
        s_suspendedCreatorList.push(creator);
        s_suspendedCreatorIndex[creator] = s_suspendedCreatorList.length - 1;

        // increase suspended creator count
        s_suspendedCreatorCount++;

        // emit event to effect
        emit CreatorSuspended(creator, msg.sender);
    }

    /**
     * @dev & @notice removes a creator from the registry
     * @param creator address of the creator to be removed
     * @dev creator can either be in `Active` or `Suspended` state
     * @dev can only be called by the admin
     */
    function removeCreator(address creator) external onlyAdmin {
        CreatorState currentState = s_creatorState[creator];

        if (currentState == CreatorState.None) {
            revert CreatorRegistry__CreatorDoesNotExist();
        } else if (currentState == CreatorState.Removed) {
            revert CreatorRegistry__CreatorAlreadyRemoved();
        }

        if (currentState == CreatorState.Suspended) {
            // remove from suspended creator list
            _removeFromArray(s_suspendedCreatorList, s_suspendedCreatorIndex, creator);

            // decrease suspended creator count
            s_suspendedCreatorCount--;
        } else if (currentState == CreatorState.Active) {
            // remove from Creator list
            _removeFromArray(s_creatorList, s_creatorIndex, creator);

            // decrease Creator count
            s_creatorCount--;
        }

        // mark as removed creator
        s_creatorState[creator] = CreatorState.Removed;

        // Add to removed creator list and track index
        s_removedCreatorList.push(creator);
        s_removedCreatorIndex[creator] = s_removedCreatorList.length - 1;

        // increase removed creator count
        s_removedCreatorCount++;

        // emit event to effect
        emit CreatorRemoved(creator, msg.sender);
    }

    /**
     * @dev & @notice updates the admin address responsible for managing the registry
     * @param newAdmin address of the new admin
     * @dev can only be called by the admin
     */
    function setAdmin(address newAdmin) external onlyAdmin {
        s_admin = newAdmin;
    }

    // >---------------------------> PUBLIC VIEW FUNCTIONS
    /// @dev returns the address of the current admin
    function getAdmin() public view returns (address) {
        return s_admin;
    }

    /// @dev returns the number of active creators in the registry
    function getCurrentCreatorCount() public view returns (uint256) {
        return s_creatorCount;
    }

    /// @dev returns the number of suspended creators in the registry
    function getSuspendedCreatorCount() public view returns (uint256) {
        return s_suspendedCreatorCount;
    }

    /// @dev returns the numberof removed creators from the registry
    function getRemovedCreatorCount() public view returns (uint256) {
        return s_removedCreatorCount;
    }

    /// @dev returns all the active creators in the registry
    function getAllCreators() public view returns (address[] memory) {
        return s_creatorList;
    }

    /// @dev returns all the suspended creators in the registry
    function getAllSuspendedCreators() public view returns (address[] memory) {
        return s_suspendedCreatorList;
    }

    /// @dev returns all the removed creators in the registry
    function getAllRemovedCreators() public view returns (address[] memory) {
        return s_removedCreatorList;
    }

    // >---------------------------> INTERNAL FUNCTIONS
    /**
     * @dev function to remove an element from an array and update the corresponding index mapping
     * @param array storage array from which the element will be removed
     * @param indexMapping mapping from element addresses to their index in the array
     * @param element address of the element to be removed from the array
     */
    function _removeFromArray(
        address[] storage array,
        mapping(address => uint256) storage indexMapping,
        address element
    ) internal {
        uint256 index = indexMapping[element];
        address lastElement = array[array.length - 1];

        // Move the last element to the deleted slot
        array[index] = lastElement;
        indexMapping[lastElement] = index;

        // Remove the last element
        array.pop();
        delete indexMapping[element];
    }
}
