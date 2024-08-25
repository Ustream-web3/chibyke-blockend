### 22/08/2024

- @note >>---> I removed this function from the [`CreatorRegistry`](./src/CreatorRegistry.sol) contract      

    ```solidity
        function _updateCreatorState(address creator, CreatorState newState) internal {
            CreatorState currentState = s_creatorState[creator];

            require(currentState != newState, "Cannot transition to same state!!!");

            if (newState == CreatorState.Suspended) {
                require(currentState == CreatorState.Active, "Can only suspend active creators!!!");
            } else if (newState == CreatorState.Removed) {
                require(
                    currentState == CreatorState.Active || currentState == CreatorState.Suspended,
                    "Can only remove active or suspended creators!!!"
                );
            }

            s_creatorState[creator] = newState;
        } 
        // @note Is there a need for this function? SHould there ever arise a situation where a creator's state need to be updated without any of the `addCreator()` `suspendCreator()` removeCreator()` functions being called?
    ```

- @note >>---> Can I make an array of addresses that will be the `s_admin` in the [`CreatorRegistry`](./src/CreatorRegistry.sol) contract? Should try it later

### 25/08/2024

- @note >>---> Below are functions which can be used to `suspend()` or `remove()` by batch. I will bring it with up during talsk with the team

    ```solidity
        function batchSuspendUsers(address[] calldata users) external onlyAdmin {
            for (uint256 i = 0; i < users.length; i++) {
                address user = users[i];
                
                // Check if the user can be suspended
                if (s_userState[user] == UserState.Active) {
                    s_userState[user] = UserState.Suspended;

                    // Remove from active list
                    _removeFromArray(s_userList, s_userIndex, user);
                    s_userCount--;

                    // Add to suspended list
                    s_suspendedUserList.push(user);
                    s_suspendedUserIndex[user] = s_suspendedUserList.length - 1;

                    s_suspendedUserCount++;

                    emit UserSuspended(user, msg.sender);
                }
            }
        }
    ```

    ```solidity
        function batchRemoveUsers(address[] calldata users) external onlyAdmin {
            for (uint256 i = 0; i < users.length; i++) {
                address user = users[i];
                UserState currentState = s_userState[user];

                // Skip if the user does not exist or is already removed
                if (currentState == UserState.None || currentState == UserState.Removed) {
                    continue;
                }

                // Handle state transition
                if (currentState == UserState.Suspended) {
                    _removeFromArray(s_suspendedUserList, s_suspendedUserIndex, user);
                    s_suspendedUserCount--;
                } else if (currentState == UserState.Active) {
                    _removeFromArray(s_userList, s_userIndex, user);
                    s_userCount--;
                }

                // Mark user as removed and add to the removed list
                s_userState[user] = UserState.Removed;
                s_removedUserList.push(user);
                s_removedUserIndex[user] = s_removedUserList.length - 1;
                s_removedUserCount++;

                emit UserRemoved(user, msg.sender);
            }
        }
    ```

### 25/08/2024 1.1

- @note >>---> Below is a function that `users` can call to leave the `Registry` of their own accord:

    ```solidity
        function leaveRegistry() external inState(msg.sender, UserState.Active) {
            // Mark the user as Removed
            s_userState[msg.sender] = UserState.Removed;

            // Remove the user from the active list
            _removeFromArray(s_userList, s_userIndex, msg.sender);
            s_userCount--;

            // Add the user to the removed list
            s_removedUserList.push(msg.sender);
            s_removedUserIndex[msg.sender] = s_removedUserList.length - 1;
            s_removedUserCount++;

            // Emit an event indicating that the user has left the registry
            emit UserRemoved(msg.sender, msg.sender);
        }
    ```

    - A few issues exist that mean this function cannot be included in the [`UserRegistry`](./src/UserRegistry.sol) for now...

        - The function marks the `user` as `Removed`, but that particular `state` is reserved for `users` that have ben removed by the `s_admin`. Should there be a new `state`?
          - Perhaps any `user` who calls this function should be marked as `None`, this way, they can join the protocl again of their own accord
        - Also, the function should check that the `user` is either `Active` or `Suspended`, instead of checking for just `Active` state like it does currently
          - But, do we want `Suspended` users to be able to join the protocol, especially if the reason for their suspension has not been addressed?
        - The event should be `Userleft`
        - Can all these be handled totally off-chain? I doubt, but is there a way that this interaction in a off-chain manner, and only changes recorded on-chain?
