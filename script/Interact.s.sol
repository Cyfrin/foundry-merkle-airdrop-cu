// SPDX-Licence-Indentifier: MIT
pragma solidity ^0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { DevOpsTools } from "foundry-devops/src/DevOpsTools.sol";
import { MerkleAirdrop } from "../src/MerkleAirdrop.sol";

contract ClaimAirdrop is Script {
    address private constant CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 private constant AMOUNT_TO_COLLECT = (25 * 1e18); // 25.000000

    bytes32 private constant PROOF_ONE = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 private constant PROOF_TWO = 0x46f4c7c1c21e8a90c03949beda51d2d02d1ec75b55dd97a999d3edbafa5a1e2f;
    bytes32[] private constant PROOF = [PROOF_ONE, PROOF_TWO];

    // These are from the default anvil key! Do not use in production
    // These will change every time the Merkle Airdrop contract is deployed
    uint8 constant V = 27;
    bytes32 constant R = 0x6c879b734e8e1ec8e571be9265166eb707fc8f9321c352ac92d097a421247a61;
    bytes32 constant S = 0x3547c3dc2b43d1525ae64bcc10681e5ded3a167d3fa288aabc053d20154b78cb;

    function claimAirdrop(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        console.log("Claiming Airdrop");
        MerkleAirdrop(mostRecentlyDeployed).claim(CLAIMING_ADDRESS, AMOUNT_TO_COLLECT, PROOF, V, R, S);
        vm.stopBroadcast();
        console.log("Claimed Airdrop");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(mostRecentlyDeployed);
    }
}

// Do not use your private key in production code - this is the anvil default private key
contract SignMessage is Script {
    uint256 constant ANVIL_PRIV_KEY =  0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    address constant CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 constant AMOUNT_TO_COLLECT = (25 * 1e18); // 25.000000

    function signMessage(address mostRecentlyDeployed) public returns (uint8 v, bytes32 r, bytes32 s) {
        vm.startBroadcast();
        bytes32 digest = MerkleAirdrop(mostRecentlyDeployed).getMessageHash(CLAIMING_ADDRESS, AMOUNT_TO_COLLECT);
        (v, r, s) = vm.sign(ANVIL_PRIV_KEY, digest);
        vm.stopBroadcast();
        console.log("v:");
        console.log(v);
        console.log("r:");
        console.logBytes32(r);
        console.log("s:");
        console.logBytes32(s);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        signMessage(mostRecentlyDeployed);
    }
}

