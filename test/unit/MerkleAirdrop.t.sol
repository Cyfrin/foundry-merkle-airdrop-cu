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

    bytes32 public merkleRoot = 0xe947b549e1f14cbad0ae5bf939b5cc4417e60cb6404c3497d970b5e2132e3562;
    uint256 amountToCollect = (25 * 1e18); // 25.000000
    uint256 amountToSend = amountToCollect * 4;
    string constant MESSAGE = "AirdropClaim(address account,uint256 amount)";

    bytes32 proofOne = 0xe48eabad7bcfec7251063d2cc38d66b3a0819db5e6a7b1afe47da4a2e412e945;
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
        console.log(user);
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
        console.log("sig", v);
        console.logBytes32(r);
        console.logBytes32(s);
        uint256 endingBalance = token.balanceOf(user);
        console.log("Ending balance: %d", endingBalance);
        assertEq(endingBalance - startingBalance, amountToCollect);
    }
}
