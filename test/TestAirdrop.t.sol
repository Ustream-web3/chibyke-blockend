// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {StreamToken} from "../src/StreamToken.sol";
import {UstreamAirdrop} from "../src/UstreamAirdrop.sol";
import {DeployAirdrop} from "../script/DeployAirdrop.s.sol";
import {Test, console2} from "forge-std/Test.sol";

contract TestAirdrop is Test {
    StreamToken token;
    UstreamAirdrop airdrop;

    bytes32 ROOT = 0xeca08e08562e1aa94451e5755a0e60d36e00ef0f598683299e78c222fbf04431;

    /// >------> proofs
    bytes32 proof_One = 0x231b342da774d4fecbe5f73f5fd0bf65c6654863260f78dd7d6f1fdf90c8588f;
    bytes32 proof_Two = 0x8c40095fbb8c28e780e50a7587124e9effa42c35a2809f1def798b184529c2c0;
    bytes32[] aliceProof = [proof_One, proof_Two];

    bytes32 proof_Three = 0x0093ffb622e5bee8f1932d098e15ecd637278cc44cb8f832fefd80398ab59eb8;
    bytes32 proof_Four = 0x8c40095fbb8c28e780e50a7587124e9effa42c35a2809f1def798b184529c2c0;
    bytes32[] bobProof = [proof_Three, proof_Four];

    bytes32 proof_Five = 0x2ef97321ca85be537fcd25acb51e65d10641c783d15eaede17e7462b2e46d2e9;
    bytes32 proof_Six = 0x2ef97321ca85be537fcd25acb51e65d10641c783d15eaede17e7462b2e46d2e9;
    bytes32[] claraProof = [proof_Five, proof_Six];

    bytes32 proof_Seven = 0x5924fe35562f107f7907224186a1f796149a9a73fa4660834eadab6e55264def;
    bytes32 proof_Eight = 0x166e1d9567635bbf199933370852d8916579822d0c76fd8fc104a43a22ec6a64;
    bytes32[] danProof = [proof_Seven, proof_Eight];

    uint256 constant CLAIM_AMOUNT = 10e18;
    uint256 constant SEND_AMOUNT = 200e18;

    address gasPayer;

    // multi receivers
    address Alice;
    uint256 alicePrvKey;
    address Bob;
    uint256 bobPrvKey;
    address Clara;
    uint256 claraPrvKey;
    address Dan;
    uint256 danPrvKey;

    function setUp() public {
        token = new StreamToken();
        airdrop = new UstreamAirdrop(ROOT, token);

        token.mint(token.owner(), SEND_AMOUNT);
        token.transfer(address(airdrop), SEND_AMOUNT);

        (Alice, alicePrvKey) = makeAddrAndKey("Alice");
        (Bob, bobPrvKey) = makeAddrAndKey("Bob");
        (Clara, claraPrvKey) = makeAddrAndKey("Clara");
        (Dan, danPrvKey) = makeAddrAndKey("Dan");

        gasPayer = makeAddr("gasPayer");
    }
}
