// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { MerkleAirdrop } from "../src/MerkleAirdrop.sol";
import { AirdropToken } from "./mocks/AirdropToken.sol";
import { Test } from "forge-std/Test.sol";

contract MerkleAirdropTest is Test {
    MerkleAirdrop public airdrop;
    AirdropToken public token;
    bytes32 public merkleRoot = 0x3b2e22da63ae414086bec9c9da6b685f790c6fab200c7918f2879f08793d77bd;
    uint256 amountToCollect = (25 * 1e6); // 25.000000
    uint256 amountToSend = amountToCollect * 4;
    address collectorOne = 0x20F41376c713072937eb02Be70ee1eD0D639966C;

    bytes32 proofOne = 0x32cee63464b09930b5c3f59f955c86694a4c640a03aa57e6f743d8a3ca5c8838;
    bytes32 proofTwo = 0x8ff683185668cbe035a18fccec4080d7a0331bb1bbc532324f40501de5e8ea5c;
    bytes32[] proof = [proofOne, proofTwo];

    function setUp() public {
        token = new AirdropToken();
        airdrop = new MerkleAirdrop(merkleRoot, token);
        token.mint(address(this), amountToSend);
        token.transfer(address(airdrop), amountToSend);
    }

    function signMessage(signer, privKey) public returns (bytes memory signature) {
        vm.startPrank(signer);
        bytes32 hash = keccak256("AirdropClaim(address account,uint256 amount)");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privKey, hash);
        address signer = ecrecover(hash, v, r, s);
        signature = abi.encodePacked(r, s, v);
        vm.stopPrank(signer);
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = token.balanceOf(collectorOne);

        (address alice, uint256 alicePk) = makeAddrAndKey("alice");
        emit log_address(alice);
        signMessage(alice, alicePk);

        airdrop.claim(collectorOne, amountToCollect, proof);
        uint256 endingBalance = token.balanceOf(collectorOne);
        assertEq(endingBalance - startingBalance, amountToCollect);
    }
    // function testUsersCanClaim() public {
    //     uint256 startingBalance = token.balanceOf(collectorOne);

    //     vm.startPrank(collectorOne);
    //     airdrop.claim(collectorOne, amountToCollect, proof);
    //     vm.stopPrank();

    //     uint256 endingBalance = token.balanceOf(collectorOne);
    //     assertEq(endingBalance - startingBalance, amountToCollect);
    // }
}
