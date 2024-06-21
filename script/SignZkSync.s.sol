// SPDX-Licence-Indentifier: MIT
pragma solidity ^0.8.24;

import { Script, console } from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

// Do not use your private key in production code - this is the anvil default private key
contract SignMessage is Script {
    uint256 private constant ANVIL_PRIV_KEY =  0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    function signMessage() public returns (uint8 v, bytes32 r, bytes32 s) {
        vm.startBroadcast();
        bytes32 DIGEST = vm.parseBytes32(vm.readFile("digest.txt"));
        (v, r, s) = vm.sign(ANVIL_PRIV_KEY, DIGEST);
        vm.stopBroadcast();
        console.log("v value:");
        console.log(v);
        console.log("r value:");
        console.logBytes32(r);
        console.log("s value:");
        console.logBytes32(s);
    }

    function run() external {
        signMessage();
    }
}

