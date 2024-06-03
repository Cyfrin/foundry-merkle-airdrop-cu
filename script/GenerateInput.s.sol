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
    uint256 amount = 25 * 1e6;
    string[] types = new string[](2);
    uint256 count;
    string[] whitelist = new string[](4);
    string private inputPath = "/script/target/input.json";
    
    function run() public {
        types[0] = "address";
        types[1] = "uint";
        whitelist[0] = "0x328809Bc894f92807417D2dAD6b7C998c1aFdac6";
        whitelist[1] = "0x277D26a45Add5775F21256159F089769892CEa5B";
        whitelist[2] = "0x0c8Ca207e27a1a8224D1b602bf856479b03319e7";
        whitelist[3] = "0xf6dBa02C01AF48Cf926579F77C9f874Ca640D91D";
        count = whitelist.length;
        string memory input = _createJSON(whitelist);
        // write to the output file the stringified output json tree dumpus 
        vm.writeFile(string.concat(vm.projectRoot(), inputPath), input);

        console.log("DONE: The output is found at %s", inputPath);
    }

    function _createJSON(string[] memory whitelist) internal view returns (string memory) {
        string memory countString = vm.toString(count); // convert count to string
        string memory amountString = vm.toString(amount); // convert amount to string
        string memory json = string.concat('{ "types": ["address", "uint"], "count":', countString, ',"values": {');
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (i == whitelist.length - 1) {
                json = string.concat(json, '"', vm.toString(i), '"', ': { "0":', '"',whitelist[i],'"',', "1":', '"',amountString,'"', ' }');
            } else {
            json = string.concat(json, '"', vm.toString(i), '"', ': { "0":', '"',whitelist[i],'"',', "1":', '"',amountString,'"', ' },');
            }
        }
        json = string.concat(json, '} }');
        
        return json;
    }
}