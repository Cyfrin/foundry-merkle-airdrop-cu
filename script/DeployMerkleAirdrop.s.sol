// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { MerkleAirdrop, IERC20 } from "../src/MerkleAirdrop.sol";
import { Script } from "forge-std/Script.sol";
import { BagelToken } from "../src/BagelToken.sol";
import { console } from "forge-std/console.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 public s_merkleRoot = 0xe947b549e1f14cbad0ae5bf939b5cc4417e60cb6404c3497d970b5e2132e3562;
    // 4 users, 25 Bagel tokens each
    uint256 public s_amountToAirdrop = 4 * (25 * 1e18);

    // Deploy the airdrop contract and bagel token contract
    function deployMerkleAirdrop() public returns (MerkleAirdrop, BagelToken) {
        vm.startBroadcast();
        BagelToken bagelToken = new BagelToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(s_merkleRoot, IERC20(bagelToken));
        // Send Bagel tokens -> Merkle Air Drop contract
        bagelToken.mint(bagelToken.owner(), s_amountToAirdrop);
        IERC20(bagelToken).transfer(address(airdrop), s_amountToAirdrop);
        vm.stopBroadcast();
        return (airdrop, bagelToken);
    }

    function run() external returns (MerkleAirdrop, BagelToken) {
        return deployMerkleAirdrop();
    }
}
