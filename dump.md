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

