// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {UserRegistry} from "../../src/UserRegistry.sol";

contract TestUserRegistry is Test {
    UserRegistry registry;

    address user = makeAddr("user");

    function setUp() public {
        registry = new UserRegistry();
    }

    function testCanCreateUserProfile() public {
        vm.startPrank(user);

        // Arrange 
        string memory userName = "Chibyke";
        string memory profileImgUri = "ipfs://cutePuppyNFT";

        // Act
        registry.createUserProfile(userName, profileImgUri);

        UserRegistry.Profile memory userProfile = registry.getUserProfileInfo(user);

        vm.stopPrank();

        // Assert
        assertEq(userProfile.userName, userName);
        assertEq(userProfile.profileImgUri, profileImgUri);
        assertEq(registry.getProfileCount(), 1); // Confirm that the profile count increased
    }

    function testCanUpdateUserProfile() public {
        vm.startPrank(user);

        // Arrange
        string memory userName = "Chibyke";
        string memory newUserName = "Proper";
        string memory profileImgUri = "ipfs://cutePuppyNFT";
        string memory newProfileImgUri = "ipfs://angryBirdNFT";

        // Act
        registry.createUserProfile(userName, profileImgUri);
        registry.updateUserProfile(newUserName, newProfileImgUri);

        UserRegistry.Profile memory userProfile = registry.getUserProfileInfo(user);

        vm.stopPrank();

        // Assert
        assertEq(userProfile.userName, newUserName);
        assertEq(userProfile.profileImgUri, newProfileImgUri);
        assertEq(registry.getProfileCount(), 1); // Confirm that the profile count did not increase
    }

    function testRevertIfUserAlreadyExists() public {
        vm.startPrank(user);

        // Arrange 
        string memory userName = "Chibyke";
        string memory profileImgUri = "ipfs://cutePuppyNFT";

        // First Act
        registry.createUserProfile(userName, profileImgUri);
        UserRegistry.Profile memory userProfile = registry.getUserProfileInfo(user);

        // First Assert
        assertEq(registry.getProfileCount(), 1); // Confirm that a profile was indeed created

        // Second Act
        vm.expectRevert(UserRegistry.UserRegistry__UserAlreadyExists.selector);

        registry.createUserProfile(userName, profileImgUri);

        // Second Assert
        assertEq(registry.getProfileCount(), 1); // Confirm that the profile count is still intact
            // Confirm that the user profile details did not change
        assertEq(userProfile.userName, userName);
        assertEq(userProfile.profileImgUri, profileImgUri);
    }

    function testRevertIfUserTriesToCreateASecondProfileWithDifferentDetails() public {
         vm.startPrank(user);

        // Arrange 
        string memory userName = "Chibyke";
        string memory profileImgUri = "ipfs://cutePuppyNFT";
        string memory newUserName = "Proper";
        string memory newProfileImgUri = "ipfs://angryBirdNFT";

        // First Act
        registry.createUserProfile(userName, profileImgUri);

        UserRegistry.Profile memory userProfile = registry.getUserProfileInfo(user);

        // First Assert
        assertEq(registry.getProfileCount(), 1); // Confirm that a profile was indeed created

        // Second Act
        vm.expectRevert(UserRegistry.UserRegistry__UserAlreadyExists.selector);
        registry.createUserProfile(newUserName, newProfileImgUri);

        // Second Assert
        assertEq(registry.getProfileCount(), 1); // Confirm that the profile count is still intact
            // Confirm that the user profile details did not change
        assertEq(userProfile.userName, userName);
        assertEq(userProfile.profileImgUri, profileImgUri);
    }

    function testCanGetProfileCount() public {
        vm.startPrank(user);

        // Arrange 
        string memory userName = "Chibyke";
        string memory profileImgUri = "ipfs://cutePuppyNFT";

        // Act
        registry.createUserProfile(userName, profileImgUri);

        vm.stopPrank();

        // Assert
        assertEq(registry.getProfileCount(), 1); // The profile count should be 1 since only one profile has been created
    }
}
