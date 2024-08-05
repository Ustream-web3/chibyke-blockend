// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @dev No initial supply specified
/// @dev I added a modifier that restricts minting of STRK to only the Guardian. There should be an automatic way to handle minting of STRK, perhaps I should create an engine contract to handle this
/// todo -> Create engine to handle minting of STRK to qualified addresses. This will be done once the team agrees on full functionality of STRK

contract StreamToken is ERC20, Ownable {
    error StreamToken__NotGuardian();
    error StreamToken__MustBeMoreThanZero();

    address public guardian;

    constructor(address _guardian) ERC20("Stream Token", "STRK") Ownable(msg.sender) {
        guardian = _guardian;
    }

    modifier onlyGuardian() {
        if (msg.sender != guardian) {
            revert StreamToken__NotGuardian();
        }
        _;
    }

    modifier mustBeMoreThanZero(uint256 amount) {
        if (amount <= 0) {
            revert StreamToken__MustBeMoreThanZero();
        }
        _;
    }

    // no need for this modifer because of the ERC20InvalidReceiver in OpenZeppelin
    // modifier mustNotBeZeroAddress(address receiver) {
    //     if (receiver == address(0)) {
    //         revert StreamToken__MustNotBeZeroAddress();
    //     }
    //     _;
    // }

    function mint(address receiver, uint256 amount) external onlyGuardian mustBeMoreThanZero(amount) {
        _mint(receiver, amount);
    }

    function setGuardian(address newGuardian) external onlyOwner {
        guardian = newGuardian;
    }
}
