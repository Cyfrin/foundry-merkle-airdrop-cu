// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Script, console } from "forge-std/Script.sol";

contract SplitSignature is Script {
    error __SplitSignatureScript__InvalidSignatureLength();

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {
        if (sig.length != 65) {
            revert __SplitSignatureScript__InvalidSignatureLength();
        }

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

    function run() external {
        string memory sig = vm.readFile("signature.txt");
        bytes memory sigBytes = vm.parseBytes(sig);
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sigBytes);
        console.log("v value:");
        console.log(v);
        console.log("r value:");
        console.logBytes32(r);
        console.log("s value:");
        console.logBytes32(s);
    }
}