// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

contract CreatorRegistry {
    // Pseudocode

    // CreatorProfile Struct
    
    // Function that creators call to be registered --> createCreatorProfile
    // Perhaps, I should create a Content.sol smart contract that inherits the CreatorRegistry contract. In this new contract, creators will add their content to the UStream platform by calling a addContent function
        // Should it be possible for an admin to be able to addContent on behalf of creators?
    // For the adding(uploading) of content, I have an idea:
        // Creators upload their content off-chain, this is to enable necessary checks to be performed by the UStream team. Approved content are issued a code which is inputted as a parameter in the addContent function
        // If this is the case, perhaps only admin should be able to addContent
        // Perhaps the Content.sol should Ownable from OpenZeppelin for more security in admin privilegdes
}
