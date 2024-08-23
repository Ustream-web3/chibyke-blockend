// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract UserRegistry is Ownable {
    // >---------------------------> ERRORS
    error UserRegistry__UserDoesNotExist();
    error UserRegistry__InvalidStateTransition();
    error UserRegistry__NotAdmin();
    error UserRegistry__UserHasBeenRemoved();

    // >---------------------------> TYPE DECLARATIONS
    enum UserState {
        None,
        Active,
        Suspended,
        Removed
    }

    // >---------------------------> STATE VARIABLES
    address private s_admin;

    uint256 private s_userCount;
    uint256 private s_suspendedUserCount;
    uint256 private s_removedUserCount;

    address[] private s_userList;
    address[] private s_suspendedUserList;
    address[] private s_removedUserList;

    mapping(address => UserState) private s_userState;

    mapping(address => uint256) private s_userIndex;
    mapping(address => uint256) private s_suspendedUserIndex;
    mapping(address => uint256) private s_removedUserIndex;

    // >---------------------------> EVENTS
    event BecameUser(address indexed user);
    event UserSuspended(address indexed suspendedUser, address indexed adminWhoSuspendedUser);
    event UserRemoved(address indexed removedUser, address indexed adminWhoRemovedUser);

    // >---------------------------> MODIFIERS
    modifier inState(address user, UserState expectedState) {
        if (s_userState[user] != expectedState) {
            revert UserRegistry__InvalidStateTransition();
        }
        _;
    }

    modifier onlyAdmin() {
        if (msg.sender != s_admin) {
            revert UserRegistry__NotAdmin();
        }
        _;
    }

    // >---------------------------> CONSTRUCTOR
    constructor() Ownable(msg.sender) {
        s_admin = msg.sender;
        s_userCount = 0;
        s_suspendedUserCount = 0;
        s_removedUserCount = 0;
    }

    // >---------------------------> EXTERNAL FUNCTIONS
    function becomeUser() external inState(msg.sender, UserState.None) {
        s_userState[msg.sender] = UserState.Active;

        s_userList.push(msg.sender);
        s_userIndex[msg.sender] = s_userList.length - 1;

        s_userCount++;

        emit BecameUser(msg.sender);
    }

    function suspendUser(address user) external onlyAdmin inState(user, UserState.Active) {
        s_userState[user] = UserState.Suspended;

        _removeFromArray(s_userList, s_userIndex, user);

        s_userCount--;

        s_suspendedUserList.push(user);
        s_suspendedUserIndex[user] = s_suspendedUserList.length - 1;

        s_suspendedUserCount++;

        emit UserSuspended(user, msg.sender);
    }

    function removeUser(address user) external onlyAdmin {
        UserState currentState = s_userState[user];

        if (currentState == UserState.None) {
            revert UserRegistry__UserDoesNotExist();
        } else if (currentState == UserState.Removed) {
            revert UserRegistry__UserHasBeenRemoved();
        }

        if (currentState == UserState.Suspended) {
            _removeFromArray(s_suspendedUserList, s_suspendedUserIndex, user);

            s_suspendedUserCount--;
        } else if (currentState == UserState.Active) {
            _removeFromArray(s_userList, s_userIndex, user);

            s_userCount--;
        }

        s_userState[user] = UserState.Removed;

        s_removedUserList.push(user);
        s_removedUserIndex[user] = s_removedUserList.length - 1;

        s_removedUserCount++;

        emit UserRemoved(user, msg.sender);
    }

    function setAdmin(address newAdmin) external onlyAdmin {
        s_admin = newAdmin;
    }

    // >---------------------------> PUBLIC VIEW FUNCTIONS
    function getAdmin() public view returns (address) {
        return s_admin;
    }

    function getCurrentUserCount() public view returns (uint256) {
        return s_userCount;
    }

    function getSuspendedUserCount() public view returns (uint256) {
        return s_suspendedUserCount;
    }

    function getRemovedUserCount() public view returns (uint256) {
        return s_removedUserCount;
    }

    function getAllUsers() public view returns (address[] memory) {
        return s_userList;
    }

    function getAllSuspendedUsers() public view returns (address[] memory) {
        return s_suspendedUserList;
    }

    function getAllRemovedUsers() public view returns (address[] memory) {
        return s_removedUserList;
    }

    // >---------------------------> INTERNAL FUNCTIONS
    function _removeFromArray(
        address[] storage array,
        mapping(address => uint256) storage indexMapping,
        address element
    ) internal {
        uint256 index = indexMapping[element];
        address lastElement = array[array.length - 1];

        array[index] = lastElement;
        indexMapping[lastElement] = index;

        array.pop();
        delete indexMapping[element];
    }
}
