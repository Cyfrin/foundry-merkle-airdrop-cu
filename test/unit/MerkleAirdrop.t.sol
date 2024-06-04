// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { MerkleAirdrop } from "../../src/MerkleAirdrop.sol";
import { BagelToken } from "../../src/BagelToken.sol";
import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";
import { DeployMerkleAirdrop } from "../../script/DeployMerkleAirdrop.s.sol";
import { Base_Test } from "../Base_Test.t.sol";

contract MerkleAirdropTest is Base_Test, Test {
    MerkleAirdrop public airdrop;
    BagelToken public token;
    address public gasPayer;
    address public user;
    uint256 public userPrivKey;

    bytes32 public merkleRoot = 0x474d994c58e37b12085fdb7bc6bbcd046cf1907b90de3b7fb083cf3636c8ebfb;
    uint256 amountToCollect = (25 * 1e18); // 25.000000
    uint256 amountToSend = amountToCollect * 4;

    bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo = 0x46f4c7c1c21e8a90c03949beda51d2d02d1ec75b55dd97a999d3edbafa5a1e2f;
    bytes32[] proof = [proofOne, proofTwo];
    
    function setUp() public {
        if (!isZkSyncChain()) {
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.deployMerkleAirdrop();
        } else {
            token = new BagelToken();
            airdrop = new MerkleAirdrop(merkleRoot, token);
            token.mint(token.owner(), amountToSend);
            token.transfer(address(airdrop), amountToSend);
        }
        gasPayer = makeAddr("gasPayer");
        (user, userPrivKey) = makeAddrAndKey("user");
    }

    function signMessage(uint256 privKey, address account) public view returns (uint8 v, bytes32 r, bytes32 s) {
        bytes32 hashedMessage = airdrop.getMessageHash(account, amountToCollect);
        (v, r, s) = vm.sign(privKey, hashedMessage);
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = token.balanceOf(gasPayer);

        // get the signature
        vm.startPrank(user);
        (uint8 v, bytes32 r, bytes32 s) = signMessage(userPrivKey, user);
        vm.stopPrank();

        // gasPayer claims the airdrop for the user
        vm.prank(gasPayer);
        airdrop.claim(user, amountToCollect, proof, v, r, s);
        uint256 endingBalance = token.balanceOf(user);
        console.log("Ending balance: %d", endingBalance);
        assertEq(endingBalance - startingBalance, amountToCollect);
    }
}
