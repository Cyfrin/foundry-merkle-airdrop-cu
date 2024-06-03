const { StandardMerkleTree } = require("@openzeppelin/merkle-tree")
const fs = require("fs")

/*//////////////////////////////////////////////////////////////
                             INPUTS
//////////////////////////////////////////////////////////////*/
const amount = (25 * 1e18).toString()
const userToGetProofOf = "0x20F41376c713072937eb02Be70ee1eD0D639966C" // user to prove that they are in the merkle tree

// (1)
const values = [
    [userToGetProofOf, amount],
    ["0x277D26a45Add5775F21256159F089769892CEa5B", amount],
    ["0x0c8Ca207e27a1a8224D1b602bf856479b03319e7", amount],
    ["0xf6dBa02C01AF48Cf926579F77C9f874Ca640D91D", amount]
]

/*//////////////////////////////////////////////////////////////
                            PROCESS
//////////////////////////////////////////////////////////////*/
// (2)
const tree = StandardMerkleTree.of(values, ["address", "uint256"])

// (3)
console.log('Merkle Root:', tree.root)

// (4)
for (const [i, v] of tree.entries()) {
    if (v[0] === userToGetProofOf) {
        // (3)
        const proof = tree.getProof(i)
        console.log(`Proof for address: ${userToGetProofOf} with amount: ${amount}:\n`, proof)
    }
}

// (5)
fs.writeFileSync("tree.json", JSON.stringify(tree.dump()))