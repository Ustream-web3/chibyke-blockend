// SPDX-License-Identifier: SEE LICENSE IN LICENSE

pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract CreatorRegistry is Ownable {
    // >---------------------------> ERRORS
    error CreatorRegistry__NotTheAdmin();
    error CreatorRegistry__CreatorExists();
    error CreatorRegistry__CreatorDoesNotExist();
    error CreatorRegistry__CreatorAlreadySuspended();
    error CreatorRegistry__CreatorAlreadyRemoved();
    error CreatorRegistry__InvalidStateTransition();

    // >---------------------------> TYPES
    enum CreatorState {
        None,
        Active,
        Suspended,
        Removed
    }

    // >---------------------------> STATE VARIABLES
    address private s_admin;

    mapping(address => CreatorState) private s_creatorState;

    address[] private s_creatorList;
    address[] private s_suspendedCreatorList;
    address[] private s_removedCreatorList;

    mapping(address => uint256) private s_creatorIndex;
    mapping(address => uint256) private s_suspendedCreatorIndex;
    mapping(address => uint256) private s_removedCreatorIndex;

    uint256 private s_creatorCount;
    uint256 private s_suspendedCreatorCount;
    uint256 private s_removedCreatorCount;

    // >---------------------------> EVENTS
    event CreatorAdded(address indexed creator, address indexed adminThatAddedCreator);
    event CreatorSuspended(address indexed creator, address indexed adminThatSuspendedCreator);
    event CreatorRemoved(address indexed creator, address indexed adminThatRemovedCreator);

    // >---------------------------> MODIFIERS
    modifier inState(address creator, CreatorState expectedState) {
        if (s_creatorState[creator] != expectedState) {
            revert CreatorRegistry__InvalidStateTransition();
        }
        _;
    }

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
     * @notice This function will suspend the creator with the inputted address
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
     * @notice This function will remove the creator with the inputted address
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

    function setAdmin(address newAdmin) external onlyAdmin {
        s_admin = newAdmin;
    }

    // >---------------------------> PUBLIC VIEW FUNCTIONS
    function getAdmin() public view returns (address) {
        return s_admin;
    }

    function getCurrentCreatorCount() public view returns (uint256) {
        return s_creatorCount;
    }

    function getSuspendedCreatorCount() public view returns (uint256) {
        return s_suspendedCreatorCount;
    }

    function getRemovedCreatorCount() public view returns (uint256) {
        return s_removedCreatorCount;
    }

    function getAllCreators() public view returns (address[] memory) {
        return s_creatorList;
    }

    function getAllSuspendedCreators() public view returns (address[] memory) {
        return s_suspendedCreatorList;
    }

    function getAllRemovedCreators() public view returns (address[] memory) {
        return s_removedCreatorList;
    }

    // >---------------------------> INTERNAL FUNCTIONS
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
