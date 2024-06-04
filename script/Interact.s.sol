// SPDX-Licence-Indentifier: MIT
pragma solidity ^0.8.24;

import { Script, console } from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

contract ClaimAirdrop is Script {
    bytes32 public merkleRoot = 0x474d994c58e37b12085fdb7bc6bbcd046cf1907b90de3b7fb083cf3636c8ebfb;
    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 amountToCollect = (25 * 1e18); // 25.000000

    bytes32 proofOne = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 proofTwo = 0x46f4c7c1c21e8a90c03949beda51d2d02d1ec75b55dd97a999d3edbafa5a1e2f;
    bytes32[] proof = [proofOne, proofTwo];

    // These are from the default anvil key! Do not use in production
    uint8 v = 27;
    bytes32 r = 0x78e335ba481e295fbb43d1981f3dfdb55c71ba21f55a3726b7c7dceb29920a41;
    bytes32 s = 0x59454dc6a6440a2c59a5f019d69c5ccfec43165aa1209ae7fa3a933f305599cf;

    function claimAirdrop(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        console.log("Claiming Airdrop");
        MerkleAirdrop(mostRecentlyDeployed).claim(CLAIMING_ADDRESS, amountToCollect, proof, v, r, s);
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
    uint256 ANVIL_PRIV_KEY =  0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 amountToCollect = (25 * 1e18); // 25.000000

    function signMessage(address mostRecentlyDeployed) public returns (uint8 v, bytes32 r, bytes32 s) {
        vm.startBroadcast();
        bytes32 digest = MerkleAirdrop(mostRecentlyDeployed).getMessageHash(CLAIMING_ADDRESS, amountToCollect);
        console.log("Signing");
        (v, r, s) = vm.sign(ANVIL_PRIV_KEY, digest);
        vm.stopBroadcast();
        console.log("v");
        console.log(v);
        console.log("r");
        console.logBytes32(r);
        console.log("s");
        console.logBytes32(s);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        signMessage(mostRecentlyDeployed);
    }
}

