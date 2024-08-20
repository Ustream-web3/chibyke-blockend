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
