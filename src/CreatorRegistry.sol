// SPDX-License-Identifier: SEE LICENSE IN LICENSE

pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract CreatorRegistry is Ownable {
    // >---------------------------> ERRORS
    error CreatorRegistry__NotTheAdmin();
    error CreatorRegistry__CreatorAlreadyAdded();
    error CreatorRegistry__CreatorAlreadySuspended();
    error CreatorRegistry__CreatorAlreadyRemoved();

    // >---------------------------> TYPE DECLARATIONS
    struct CreatorProfile {
        address creator;
        uint256 creatorId;
    }

    // >---------------------------> STATE VARIABLES
    address private s_admin;
    uint256 creatorCount;
    mapping(address => CreatorProfile) private s_creators;
    mapping(address => bool) private s_creatorsApproved;

    mapping(address => uint256) private s_creatorToCreatorId;
    mapping(uint256 => address) private s_creatorIdToCreator;

    address[] private s_suspendedCreators;
    address[] private s_removedCreators;

    // >---------------------------> EVENTS
    event CreatorAdded(address indexed creator, uint256 indexed creatorId);
    event CreatorSuspended(address indexed creator, uint256 indexed creatorId);
    event CreatorRemoved(address indexed creator, uint256 indexed creatorId);

    // >---------------------------> MODIFIERS
    modifier creatorAlreadyAdded(address creator, uint256 creatorId) {
        if (s_creatorsApproved[creator]) {
            revert CreatorRegistry__CreatorAlreadyAdded();
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
    }

    // >---------------------------> EXTERNAL FUNCTIONS
    function addCreator(address creator, uint256 creatorId)
        external
        creatorAlreadyAdded(creator, creatorId)
        onlyAdmin
    {
        s_creators[creator] = CreatorProfile(creator, creatorId);
        s_creatorsApproved[creator] = true;

        emit CreatorAdded(creator, creatorId);

        creatorCount++;
    }

    /**
     * @notice This function will suspend the creator with the inputted address and creatorId
     */
    function suspendCreator() external onlyAdmin {}

    /**
     * @notice This function will remove the creator with the inputted address and creatorId
     */
    function removeCreator() external onlyAdmin {}

    // >---------------------------> EXTERNAL VIEW FUNCTIONS

    /**
     * @notice this function will return the creator address of the inputted creatorId
     */
    function getAddedCreator(uint256 creatorId) external view returns (address) {}

    /**
     * @notice This function will return the creatorId of the inputted creator address
     */
    function getAddedCreatorId(address creator) external view returns (uint256) {}
}
