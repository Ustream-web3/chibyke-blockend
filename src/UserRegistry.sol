// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

contract UserRegistry {
    // >---------------------------> ERRORS
    error UserRegistry__UserAlreadyExists();
    error UserRegistry__UserDoesNotExist();

    // >---------------------------> TYPE DECLARATIONS
    struct Profile {
        string userName;
        string profileImgUri; // Will have to figure out a way to do this. Can there be a way for us to get the profileImgUri onchain if the profileImg is not an NFT?
    }
    // >---------------------------> STATE VARIABLES

    uint256 profileCount;

    mapping(address => Profile) private s_profiles;
    mapping(address => bool) private s_profileCreated;

    // >---------------------------> EVENTS
    event ProfileCreated(string userName, string profileImgUri);
    event ProfileUpdated(string newUserName, string newProfileImgUri);

    // >---------------------------> MODIFIERS
    modifier userAlreadyExists() {
        if (s_profileCreated[msg.sender]) {
            revert UserRegistry__UserAlreadyExists();
        }
        _;
    }

    modifier userDoesNotExist() {
        if (!s_profileCreated[msg.sender]) {
            revert UserRegistry__UserDoesNotExist();
        }
        _;
    }

    // >---------------------------> CONSTRUCTOR
    constructor() {
        profileCount = 0;
    }

    // >---------------------------> EXTERNAL FUNCTIONS
    function createUserProfile(string memory userName_, string memory profileImgUri_) external userAlreadyExists {
        s_profiles[msg.sender] = Profile(userName_, profileImgUri_);
        s_profileCreated[msg.sender] = true;

        emit ProfileCreated(userName_, profileImgUri_);

        profileCount++;
    }

    function updateUserProfile(string memory newUserName_, string memory newProfileImgUri_) external userDoesNotExist {
        s_profiles[msg.sender] = Profile(newUserName_, newProfileImgUri_);

        emit ProfileUpdated(newUserName_, newProfileImgUri_);
    }

    // >---------------------------> EXTERNAL VIEW FUNCTIONS
    function getUserProfileInfo(address userAddress_) external view returns (Profile memory) {
        return s_profiles[userAddress_];
    }

    function getProfileCount() external view returns (uint256) {
        return profileCount;
    }
}
