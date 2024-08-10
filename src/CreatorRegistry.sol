// SPDX-License-Identifier: SEE LICENSE IN LICENSE

pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract CreatorRegistry is Ownable {
    // >---------------------------> ERRORS
    error CreatorRegistry__CreatorAlreadyApproved();
    error CreatorRegistry__NotTheAdmin();

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

    // >---------------------------> EVENTS
    event CreatorAdded(address indexed creator, uint256 indexed creatorId);

    // >---------------------------> MODIFIERS
    modifier creatorAlreadyAdded(address creator, uint256 creatorId) {
        if (s_creatorsApproved[creator]) {
            revert CreatorRegistry__CreatorAlreadyApproved();
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

    function removeCreator() external {}
}
