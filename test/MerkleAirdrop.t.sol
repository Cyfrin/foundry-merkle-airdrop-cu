// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { MerkleAirdrop } from "../src/MerkleAirdrop.sol";
import { AirdropToken } from "./mocks/AirdropToken.sol";
import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";

contract MerkleAirdropTest is Test {
    MerkleAirdrop public airdrop;
    AirdropToken public token;
    address public gasPayer;
    address public user;
    uint256 public userPrivKey;

    bytes32 public merkleRoot = 0xcbe9ca252293f2987f7a0ec1cb4f5312583a07d69ab0f5d2d8c28092c084c326;
    uint256 amountToCollect = (25 * 1e6); // 25.000000
    uint256 amountToSend = amountToCollect * 4;

    bytes32 proofOne = 0x1e6784ff835523401f4db6e3ab48fa5bdf523a46a5bc0410a5639d837352b194;
    bytes32 proofTwo = 0x6d03f01cc9fb12c48e1c8d9f3f9425f48f664fa9cf3520a6d0c993d01ed00e45;
    bytes32[] proof = [proofOne, proofTwo];

    function setUp() public {
        gasPayer = makeAddr("gasPayer");
        (user, userPrivKey) = makeAddrAndKey("user");

        token = new AirdropToken();
        airdrop = new MerkleAirdrop(merkleRoot, token);
        token.mint(address(this), amountToSend);
        token.transfer(address(airdrop), amountToSend);
    }

    function signMessage(address signer, uint256 privKey) public returns (uint8 v, bytes32 r, bytes32 s) {
        vm.startPrank(signer);
        bytes32 hash = keccak256("AirdropClaim(address account,uint256 amount)");
        (v, r, s) = vm.sign(privKey, hash);
        vm.stopPrank();
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = token.balanceOf(gasPayer);

        // get the signature
        (uint8 v, bytes32 r, bytes32 s) = signMessage(user, userPrivKey);

        // gasPayer claims the airdrop for the user
        vm.prank(gasPayer);
        airdrop.claim(user, amountToCollect, proof, v, r, s);
        uint256 endingBalance = token.balanceOf(gasPayer);
        assertEq(endingBalance - startingBalance, amountToCollect);
    }
}
