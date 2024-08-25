### 20/08/2024

- About to do a major refactoring on [`CreatorRegistry`](./src/CreatorRegistry.sol) contract. 
- Here is the current state of the contract before refactoring:
  
    ```solidity
    // SPDX-License-Identifier: SEE LICENSE IN LICENSE

    pragma solidity ^0.8.24;

    import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

    contract CreatorRegistry is Ownable {
        // >---------------------------> ERRORS
        error CreatorRegistry__NotTheAdmin();
        error CreatorRegistry__CreatorAlreadyAdded();
        error CreatorRegistry__CreatorDoesNotExist();
        error CreatorRegistry__CreatorAlreadySuspended();
        error CreatorRegistry__CreatorAlreadyRemoved();

        // >---------------------------> TYPE DECLARATIONS
        struct AddedCreator {
            address creator;
            uint256 creatorId;
        }

        struct SuspendedCreator {
            address creator;
            uint256 creatorId;
        }

        struct RemovedCreator {
            address creator;
            uint256 creatorId;
        } // since the creator (and accompanying creatorId will be totally removed from the protocol, is there any need for this struct?)

        // >---------------------------> STATE VARIABLES
        address private s_admin;
        uint256 private s_creatorCount;

        mapping(address => AddedCreator) private s_addedCreators;
        mapping(address => SuspendedCreator) private s_suspendedCreators;
        mapping(address => RemovedCreator) private s_removedCreators;

        mapping(address => bool) private s_isAddedCreator;
        mapping(uint256 => bool) private s_isAddedCreatorId;

        mapping(address => uint256) private s_creatorToCreatorId;
        mapping(uint256 => address) private s_creatorIdToCreator;

        mapping(address => bool) private s_isSuspendedCreator;
        mapping(uint256 => bool) private s_isSuspendedCreatorId;

        mapping(address => bool) private s_isRemovedCreator;
        mapping(uint256 => bool) private s_isRemovedCreatorId;

        // >---------------------------> EVENTS
        event CreatorAdded(address indexed creator, uint256 indexed creatorId, address indexed adminThatAddedCreator);
        event CreatorSuspended(
            address indexed creator, uint256 indexed creatorId, address indexed adminThatSuspendedCreator
        );
        event CreatorRemoved(address indexed creator, uint256 indexed creatorId, address indexed adminThatRemovedCreator);

        // >---------------------------> MODIFIERS
        modifier alreadyAdded(address creator, uint256 creatorId) {
            if (s_isAddedCreator[creator] && s_isAddedCreatorId[creatorId]) {
                revert CreatorRegistry__CreatorAlreadyAdded();
            }
            _;
        }

        modifier alreadyExists(address creator, uint256 creatorId) {
            if (!s_isAddedCreator[creator] && !s_isAddedCreatorId[creatorId]) {
                revert CreatorRegistry__CreatorDoesNotExist();
            }
            _;
        }

        modifier notAlreadySuspended(address creator, uint256 creatorId) {
            if (s_isSuspendedCreator[creator] && s_isSuspendedCreatorId[creatorId]) {
                revert CreatorRegistry__CreatorAlreadySuspended();
            }
            _;
        }

        modifier notAlreadyRemoved(address creator, uint256 creatorId) {
            if (s_isRemovedCreator[creator] && s_isRemovedCreatorId[creatorId]) {
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
        }

        // >---------------------------> EXTERNAL FUNCTIONS
        function addCreator(address creator, uint256 creatorId) external onlyAdmin alreadyAdded(creator, creatorId) {
            s_addedCreators[creator] = AddedCreator(creator, creatorId);
            s_isAddedCreator[creator] = true;
            s_isAddedCreatorId[creatorId] = true;

            emit CreatorAdded(creator, creatorId, msg.sender);

            s_creatorCount++;
        }

        /**
        * @notice This function will suspend the creator with the inputted address and creatorId
        */
        function suspendCreator(address creator, uint256 creatorId)
            external
            onlyAdmin
            alreadyExists(creator, creatorId)
            notAlreadySuspended(creator, creatorId)
            notAlreadyRemoved(creator, creatorId)
        {
            // I should add a check that ensures that the inputted pair of address and id actually match. Can a keccakk do this?

            // remove from added creators
            delete s_addedCreators[creator];
            delete s_isAddedCreator[creator];
            delete s_isAddedCreatorId[creatorId];

            // add to suspended creators
            s_suspendedCreators[creator] = SuspendedCreator(creator, creatorId);
            s_isSuspendedCreator[creator] = true;
            s_isSuspendedCreatorId[creatorId] = true;

            emit CreatorSuspended(creator, creatorId, msg.sender);

            s_creatorCount--;
        }

        /**
        * @notice This function will remove the creator with the inputted address and creatorId
        */
        function removeCreator(address creator, uint256 creatorId)
            external
            onlyAdmin
            alreadyExists(creator, creatorId)
            notAlreadyRemoved(creator, creatorId)
        {
            // Remove from added creators
            delete s_addedCreators[creator];
            delete s_isAddedCreator[creator];
            delete s_isAddedCreatorId[creatorId];

            // Mark as removed
            s_removedCreators[creator] = RemovedCreator(creator, creatorId);
            s_isRemovedCreator[creator] = true;
            s_isRemovedCreatorId[creatorId] = true;
        }

        // >---------------------------> PUBLIC VIEW FUNCTIONS

        /**
        * @notice this function will return the creator address of the inputted creatorId
        */
        function getCreator(uint256 creatorId) public view returns (address) {
            return s_creatorIdToCreator[creatorId];
        }

        /**
        * @notice This function will return the creatorId of the inputted creator address
        */
        function getCreatorId(address creator) public view returns (uint256) {
            return s_creatorToCreatorId[creator];
        }

        function getAdmin() public view returns (address) {
            return s_admin;
        }

        function getCurrentCreatorCount() public view returns (uint256) {
            return s_creatorCount;
        }
    }
    ```

- In the refactored contract; 
  - there will be no need for a creatorId (at least on-chain)
  - onlyAdmin can add creators to the platform 
    - (I should look into having multiple admins for the platform as against only just the deployer of the contract)
  - Intending creators fill a form on the platfomr with the required details. Verified applicants are added to the platform by the Admin

-------------------------------

### 22/08/2024

- Here is the current state of the [`CreatorRegistry`](./src/CreatorRegistry.sol) contract after first phase of major refactoring:

    ```solidity
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

        mapping(address => bool) private s_isCreator;
        mapping(address => bool) private s_isSuspendedCreator;
        mapping(address => bool) private s_isRemovedCreator;

        address[] private s_creatorList;
        address[] private s_suspendedCreatorList;
        address[] private s_removedCreatorList;

        uint256 private s_creatorCount;
        uint256 private s_suspendedCreatorCount;
        uint256 private s_removedCreatorCount;

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
            // mark as Creator
            s_isCreator[applicant] = true;

            // add to creator list
            s_creatorList.push(applicant);

            // increase Creator count
            s_creatorCount++;

            // emit event to effect
            emit CreatorAdded(applicant, msg.sender);
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
            // mark as not Creator
            s_isCreator[creator] = false;

            // remove from creator list
            _removeFromArray(s_creatorList, creator);

            // decrease Creator count
            s_creatorCount--;

            // mark as suspended Creator
            s_isSuspendedCreator[creator] = true;

            // add to suspended creator list
            s_suspendedCreatorList.push(creator);

            // increase suspended Creator count
            s_suspendedCreatorCount++;

            // emit event to effect
            emit CreatorSuspended(creator, msg.sender);
        }

        /**
        * @notice This function will remove the creator with the inputted address
        */
        function removeCreator(address creator) external onlyAdmin alreadyCreator(creator) notAlreadyRemoved(creator) {
            if (s_isSuspendedCreator[creator]) {
                // mark as not suspended Creator
                s_isSuspendedCreator[creator] = false;

                // remove from suspended creator list
                _removeFromArray(s_suspendedCreatorList, creator);

                // decrease suspended Creators count
                s_suspendedCreatorCount--;
            } else {
                // mark as not Creator
                s_isCreator[creator] = false;

                // remove from creator list
                _removeFromArray(s_creatorList, creator);

                // decrease Creator count
                s_creatorCount--;
            }

            // mark as removed Creator
            s_isRemovedCreator[creator] = true;

            // add to removed creator list
            s_removedCreatorList.push(creator);

            // increase removed Creator count
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
        function _removeFromArray(address[] storage array, address element) internal {
            for (uint256 a = 0; a < array.length; a++) {
                if (array[a] == element) {
                    array[a] = array[array.length - 1];
                    array.pop();
                    break;
                }
            }
        }
    }
    ```

- `creatorId` has been phased out

----------------------------------------------

### 22/08/2024 1.1

- Here is the current state of [`UserRegistry`](./src/UserRegistry.sol) contract before refactoring:

    ```solidity
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
    ```

- Proposed changes in upcoming refactoring:
  - Pfp image will be an off-chain selection, the smart contract will not keep track of this
  - There will be functions to suspend and remove users by the admin
  - And some more...

### 25/08/2024

- There should be a `leaveRegistry()` function that `users` can call to leave the protocol of their own accord.... check [`dump.md`](./dump.md) for dump note marked `###25/08/2024 1.1` 