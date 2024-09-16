// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {StreamToken} from "./StreamToken.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract UstreamAirdrop is EIP712, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// >-----> error
    error UA__InvalidProof();
    error UA__AlreadyClaimed();
    error UA__InvalidSignature();

    /// >------> type declaration
    struct AirdropClaim {
        address receiver;
        uint256 amount;
    }

    /// >------> variables
    address[] private s_claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address receiver, uint256 amount)");
    mapping(address => bool) private s_hasClaimed;

    /// >------> events
    event StrkClaimed(address indexed claimer, uint256 amount);

    /// >------> constructor
    constructor(bytes32 merkleRoot, IERC20 airdropToken) EIP712("StreamAirdrop", "1") {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    /// >------> external functions
    function claim(address receiver, uint256 amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s)
        external
        nonReentrant
    {
        if (s_hasClaimed[receiver]) {
            revert UA__AlreadyClaimed();
        }

        if (!_isValidSignature(receiver, getMessageHash(receiver, amount), v, r, s)) {
            revert UA__InvalidSignature();
        }

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(receiver, amount))));

        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert UA__InvalidProof();
        }

        s_hasClaimed[receiver] = true;

        s_claimers.push(receiver);

        emit StrkClaimed(receiver, amount);

        i_airdropToken.safeTransfer(receiver, amount);
    }

    /// >------> internal functions
    function _isValidSignature(address receiver, bytes32 digest, uint8 v, bytes32 r, bytes32 s)
        internal
        pure
        returns (bool)
    {
        (address actualSigner,,) = ECDSA.tryRecover(digest, v, r, s);
        return actualSigner == receiver;
    }

    /// >------> external & public view functions
    function getMessageHash(address receiver, uint256 amount) public view returns (bytes32) {
        return _hashTypedDataV4(
            keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({receiver: receiver, amount: amount})))
        );
    }
}
