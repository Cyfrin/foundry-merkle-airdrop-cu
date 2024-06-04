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

    bytes32 public merkleRoot = 0x99df63596361a38cff50fa0d2cf8c3550da341ad5ebb1a6d9733fefb56c3b4a4;
    uint256 amountToCollect = (25 * 1e6); // 25.000000
    uint256 amountToSend = amountToCollect * 4;
    string constant MESSAGE = "AirdropClaim(address account,uint256 amount)";

    bytes32 proofOne = 0x1e6784ff835523401f4db6e3ab48fa5bdf523a46a5bc0410a5639d837352b194;
    bytes32 proofTwo = 0x6d03f01cc9fb12c48e1c8d9f3f9425f48f664fa9cf3520a6d0c993d01ed00e45;
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
        console.log("V:", v);
        console.logBytes32(r);
        console.logBytes32(s);
        vm.stopPrank();

        // gasPayer claims the airdrop for the user
        vm.prank(gasPayer);
        airdrop.claim(user, amountToCollect, proof, v, r, s);
        uint256 endingBalance = token.balanceOf(user);
        console.log("Ending balance: %d", endingBalance);
        assertEq(endingBalance - startingBalance, amountToCollect);
    }
}
