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
    bytes32[] private proof = [PROOF_ONE, PROOF_TWO];

    // this will change every time!
    bytes private SIGNATURE = hex"6c879b734e8e1ec8e571be9265166eb707fc8f9321c352ac92d097a421247a613547c3dc2b43d1525ae64bcc10681e5ded3a167d3fa288aabc053d20154b78cb1b";

    function claimAirdrop(address mostRecentlyDeployed) public {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(SIGNATURE);
        console.log(v);
        vm.startBroadcast();
        console.log("Claiming Airdrop");
        MerkleAirdrop(mostRecentlyDeployed).claim(CLAIMING_ADDRESS, AMOUNT_TO_COLLECT, proof, v, r, s);
        vm.stopBroadcast();
        console.log("Claimed Airdrop");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(mostRecentlyDeployed);
    }

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
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
        console.log("digest:");
        console.logBytes32(digest);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        signMessage(mostRecentlyDeployed);
    }
}

