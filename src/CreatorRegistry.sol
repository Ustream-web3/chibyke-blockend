// SPDX-License-Identifier: SEE LICENSE IN LICENSE

pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract CreatorRegistry is Ownable {
    // >---------------------------> ERRORS
    error CreatorRegistry__CreatorAlreadyApproved();

    // >---------------------------> TYPE DECLARATIONS
    struct CreatorProfile {
        address creator;
        uint256 creatorId;
    }

    // >---------------------------> STATE VARIABLES
    uint256 creatorCount;
    mapping(address => CreatorProfile) private s_creators;
    mapping(address => bool) private s_creatorApproved;

    // >---------------------------> EVENTS
    event CreatorAdded(address indexed creator, uint256 indexed creatorId);

    // >---------------------------> MODIFIERS
    modifier creatorAlreadyAdded(address creator, uint256 creatorId) {
        if (s_creatorApproved[creator]) {
            revert CreatorRegistry__CreatorAlreadyApproved();
            _;
        }
    }

    // >---------------------------> CONSTRUCTOR
    constructor() Ownable(msg.sender) {}
}
