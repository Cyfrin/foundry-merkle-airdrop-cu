// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { MerkleAirdrop, IERC20 } from "../src/MerkleAirdrop.sol";
import { Script } from "forge-std/Script.sol";
import { BagelToken } from "../src/BagelToken.sol";
import { console } from "forge-std/console.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    // 4 users, 25 Bagel tokens each
    uint256 public AMOUNT_TO_TRANSFER = 4 * (25 * 1e18);

    // Deploy the airdrop contract and bagel token contract
    function deployMerkleAirdrop() public returns (MerkleAirdrop, BagelToken) {
        vm.startBroadcast();
        BagelToken bagelToken = new BagelToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(ROOT, IERC20(bagelToken));
        // Send Bagel tokens -> Merkle Air Drop contract
        bagelToken.mint(bagelToken.owner(), AMOUNT_TO_TRANSFER);
        IERC20(bagelToken).transfer(address(airdrop), AMOUNT_TO_TRANSFER);
        vm.stopBroadcast();
        return (airdrop, bagelToken);
    }

    function run() external returns (MerkleAirdrop, BagelToken) {
        return deployMerkleAirdrop();
    }
}
