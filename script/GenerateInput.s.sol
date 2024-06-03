// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {console} from "forge-std/console.sol";
import {Merkle} from "murky/src/Merkle.sol";
import {ScriptHelper} from "murky/script/common/ScriptHelper.sol";

// Merkle tree input file generator script
// To use:
// 1. Update the input.json file in /script/target/input.json
// 2. Run `forge script script/GenerateInput.s.sol`
// 3. The input file will be generated in /script/target/input.json

// {
//     "types": [
//         "address",
//         "uint"
//     ],
//     "count": 3,
//     "values": {
//         "0": {
//             "0": "0x277D26a45Add5775F21256159F089769892CEa5B",
//             "1": "25000000000000000000"
//         },
//         "1": {
//             "0": "0x0c8Ca207e27a1a8224D1b602bf856479b03319e7",
//             "1": "25000000000000000000"
//         },
//         "2": {
//             "0": "0xf6dBa02C01AF48Cf926579F77C9f874Ca640D91D",
//             "1": "25000000000000000000"
//         }
//     }
// }
/// @notice Generates the input JSON file for the merkle tree
/// @author kootsZhin
contract GenerateInput is Script {
    uint256 amount = 25 * 1e18;
    address userToGetProofOf = 0x20F41376c713072937eb02Be70ee1eD0D639966C;

    mapping(address => uint256) values;
    
    function run() public {
        values[userToGetProofOf] = amount;
        values[0x277D26a45Add5775F21256159F089769892CEa5B] = amount;
        values[0x0c8Ca207e27a1a8224D1b602bf856479b03319e7] = amount;
        values[0xf6dBa02C01AF48Cf926579F77C9f874Ca640D91D] = amount;

        // string memory result = string.concat(
        //     "{",
        //     "\"types\":",
        //     _types,
        //     ",",
        //     "\"proof\":",
        //     _proof,
        //     ",",
        //     "\"root\":\"",
        //     _root,
        //     "\",",
        //     "\"leaf\":\"",
        //     _leaf,
        //     "\"",
        //     "}"
        // );
    }
}