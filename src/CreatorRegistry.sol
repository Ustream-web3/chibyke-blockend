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

    // >---------------------------> STATE VARIABLES
    address private s_admin;
    uint256 private s_creatorCount;
    uint256 private s_suspendedCreatorCount;
    uint256 private s_removedCreatorCount;
    address[] private s_Creators;
    address[] private s_suspendedCreators;
    address[] private s_removedCreators;

    mapping(address => bool) private s_isCreator;
    mapping(address => bool) private s_isSuspendedCreator;
    mapping(address => bool) private s_isRemovedCreator;

    // >---------------------------> EVENTS
    event CreatorAdded(address indexed creator, address indexed adminThatAddedCreator);
    event CreatorSuspended(address indexed creator, address indexed adminThatSuspendedCreator);
    event CreatorRemoved(address indexed creator, address indexed adminThatRemovedCreator);

    // >---------------------------> MODIFIERS
    modifier alreadyCreator(address creator) {
        if (!s_isCreator[creator]) {
            revert CreatorRegistry__CreatorDoesNotExist();
        }
        _;
    }

    modifier notAlreadyCreator(address applicant) {
        if (s_isCreator[applicant]) {
            revert CreatorRegistry__CreatorExists();
        }
        _;
    }

    modifier notAlreadySuspended(address creator) {
        if (s_isSuspendedCreator[creator]) {
            revert CreatorRegistry__CreatorAlreadySuspended();
        }
        _;
    }

    modifier notAlreadyRemoved(address creator) {
        if (s_isRemovedCreator[creator]) {
            revert CreatorRegistry__CreatorAlreadyRemoved();
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
    function addCreator(address applicant) external onlyAdmin notAlreadyCreator(applicant) {
        // add to Creators
        s_Creators.push(applicant);

        // mark as Creator
        s_isCreator[applicant] = true;

        // emit event to effect
        emit CreatorAdded(applicant, msg.sender);

        s_creatorCount++;
    }

    /**
     * @notice This function will suspend the creator with the inputted address
     */
    function suspendCreator(address creator)
        external
        onlyAdmin
        alreadyCreator(creator)
        notAlreadySuspended(creator)
        notAlreadyRemoved(creator)
    {
        // remove from Creators
        s_Creators.pop();
        s_isCreator[creator] = false;

        // add to suspended Creators
        s_suspendedCreators.push(creator);

        // mark as suspended Creator
        s_isSuspendedCreator[creator] = true;

        // emit event to effect
        emit CreatorSuspended(creator, msg.sender);

        // decrease Creator count
        s_creatorCount--;

        // increase suspended Creator count
        s_suspendedCreatorCount++;
    }

    /**
     * @notice This function will remove the creator with the inputted address
     */
    function removeCreator(address creator) external onlyAdmin alreadyCreator(creator) notAlreadyRemoved(creator) {
        if (s_isSuspendedCreator[creator]) {
            // remove from suspended Creators
            s_suspendedCreators.pop();
            s_isSuspendedCreator[creator] = false;

            // add to removed Creators
            s_removedCreators.push(creator);

            // mark as removed Creator
            s_isRemovedCreator[creator] = true;

            // decrease suspended Creators count
            s_suspendedCreatorCount--;
        } else {
            // remove from Creators
            s_Creators.pop();
            s_isCreator[creator] = false;

            // add to removed Creators
            s_removedCreators.push(creator);

            // mark as removed Creator
            s_isRemovedCreator[creator] = true;
        }

        // emit event to effect
        emit CreatorRemoved(creator, msg.sender);

        // decrease Creator count
        s_creatorCount--;

        // increase removed Creator count
        s_removedCreatorCount++;
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
}
