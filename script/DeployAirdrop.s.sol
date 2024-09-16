// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {UstreamAirdrop} from "../src/UstreamAirdrop.sol";
import {StreamToken} from "../src/StreamToken.sol";
import {Script} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployAirdrop is Script {
    bytes32 private s_merkleRoot = 0xeca08e08562e1aa94451e5755a0e60d36e00ef0f598683299e78c222fbf04431;
    uint256 constant MINT_AMOUNT = 200e18;

    function deployAirdrop() public returns (UstreamAirdrop, StreamToken) {
        vm.startBroadcast();
        StreamToken token = new StreamToken();
        UstreamAirdrop airdrop = new UstreamAirdrop(s_merkleRoot, IERC20(address(token)));

        token.mint(token.owner(), MINT_AMOUNT);
        token.transfer(address(airdrop), MINT_AMOUNT);

        vm.stopBroadcast();

        return (airdrop, token);
    }

    function run() external returns (UstreamAirdrop, StreamToken) {
        return deployAirdrop();
    }
}
