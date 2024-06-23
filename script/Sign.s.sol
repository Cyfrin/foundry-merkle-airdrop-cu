// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { DevOpsTools } from "foundry-devops/src/DevOpsTools.sol";
import { MerkleAirdrop } from "../src/MerkleAirdrop.sol";

contract Sign is Script {
    uint256 constant AMOUNT_TO_COLLECT = (25 * 1e18); // 25.000000
    function signMessage(address airdrop) public returns (uint8 v, bytes32 r, bytes32 s){
        bytes32 digest = MerkleAirdrop(airdrop).getMessageHash(msg.sender, AMOUNT_TO_COLLECT);
        console.log("digest value:");
        console.logBytes32(digest);
        (v, r, s) = vm.sign(msg.sender, digest);
        console.log("v value:");
        console.log(v);
        console.log("r value:");
        console.logBytes32(r);
        console.log("s value:");
        console.logBytes32(s);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        signMessage(mostRecentlyDeployed);
    }
}