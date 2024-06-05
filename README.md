## Merkle Airdrop Extravaganza 

This is a section of the Cyfrin Advanced Foundry Course.

- [Merkle Airdrop Extravaganza](#merkle-airdrop-extravaganza)
- [Getting Started](#getting-started)
  - [Requirements](#requirements)
  - [Quickstart](#quickstart)
    - [Optional Gitpod](#optional-gitpod)
- [Usage](#usage)
  - [Deploy](#deploy)
  - [Testing](#testing)
    - [Test Coverage](#test-coverage)
  - [Local zkSync](#local-zksync)
    - [(Additional) Requirements](#additional-requirements)
    - [Setup local zkSync node](#setup-local-zksync-node)
    - [Deploy to local zkSync node](#deploy-to-local-zksync-node)
- [Deployment to a testnet or mainnet](#deployment-to-a-testnet-or-mainnet)
  - [Scripts](#scripts)
    - [Withdraw](#withdraw)
  - [Estimate gas](#estimate-gas)
- [Formatting](#formatting)
- [Thank you!](#thank-you)

# Getting Started

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [foundry](https://getfoundry.sh/)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`


## Quickstart

```
git clone https://github.com/ciara/merkle-airdrop
cd merkle-airdrop
forge build
```

# Usage

If not updating the array of addresses, skip to [deploy](#deploy)

If updating the array of addresses, you will need to follow the following:

First, the array of addresses to airdrop to needs to be updated in `GenerateInput.s.sol. To generate the input file and then the merkle root and proofs, run the following:

Using make:

```
make merkle
```

Or using the commands directly:

```
forge script script/GenerateInput.s.sol:GenerateInput && forge script script/MakeMerkle.s.sol:MakeMerkle
```

Then, retrieve the `root` from `script/target/output.json` and paste it in the `Makefile` as `ROOT` (for zkSync deployments) and update `s_merkleRoot` in `DeployMerkleAirdrop.s.sol` for Ethereum/Anvil deployments.

## Deploy

Deploy to Anvil:

```
make deploy
```

Deploy to a zkSync local node:

```
make deploy-zk
```

Deploy to zkSync Sepolia:

```
make deploy-zk-sepolia
```

## Interacting

On Anvil, run the following command after deploying the `MerkleAirdrop` contract:

```
make sign
```

Retrieve the `v`, `r`, and `s` values outputted to the terminal and add them to `Interact.s.sol`. Additionally, if you have modified the claiming addresses in the merkle tree, you will need to update the proofs in this file too (which you can get from `output.json`)

Then run the following command:

```
make claim
```

Then, check the claiming address balance has increased by running

```
cast call ${BAGEL_TOKEN} "balanceOf(address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
```

Where ${BAGEL_TOKEN} is the contract address of the Bagel Token which you can find in your terminal and 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 is the default anvil address which has recieved the airdropped tokens using the second default anvil key (0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d) to pay the gas using their signature

Then run the following to convert the hex to decimal on the output:

```
cast --to-dec ${BALANCE_HEX}
```

## Testing


```
forge test
```

for for zkSync

```
make zktest
```

or 

```
// Only run test functions matching the specified regex pattern.

"forge test -m testFunctionName" is deprecated. Please use 

forge test --match-test testFunctionName
```

or

```
forge test --fork-url $SEPOLIA_RPC_URL
```

### Test Coverage

```
forge coverage
```

## Local zkSync 

The instructions here will allow you to work with this repo on zkSync.

### (Additional) Requirements 

In addition to the requirements above, you'll need:
- [foundry-zksync](https://github.com/matter-labs/foundry-zksync)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.0.2 (816e00b 2023-03-16T00:05:26.396218Z)`. 
- [npx & npm](https://docs.npmjs.com/cli/v10/commands/npm-install)
  - You'll know you did it right if you can run `npm --version` and you see a response like `7.24.0` and `npx --version` and you see a response like `8.1.0`.
- [docker](https://docs.docker.com/engine/install/)
  - You'll know you did it right if you can run `docker --version` and you see a response like `Docker version 20.10.7, build f0df350`.
  - Then, you'll want the daemon running, you'll know it's running if you can run `docker --info` and in the output you'll see something like the following to know it's running:
```bash
Client:
 Context:    default
 Debug Mode: false
```

### Setup local zkSync node 

Run the following:

```bash
npx zksync-cli dev config
```

And select: `In memory node` and do not select any additional modules.

Then run:
```bash
npx zksync-cli dev start
```

And you'll get an output like:
```
In memory node started v0.1.0-alpha.22:
 - zkSync Node (L2):
  - Chain ID: 260
  - RPC URL: http://127.0.0.1:8011
  - Rich accounts: https://era.zksync.io/docs/tools/testing/era-test-node.html#use-pre-configured-rich-wallets
```

### Deploy to local zkSync node

```bash
make deploy-zk
```

# Deployment to a testnet or mainnet

1. Setup environment variables

You'll want to set your `SEPOLIA_RPC_URL`, `ZKSYNC_SEPOLIA_RPC_URL` and `PRIVATE_KEY` as environment variables. You can add them to a `.env` file, similar to what you see in `.env.example`.

- `PRIVATE_KEY`: The private key of your account (like from [metamask](https://metamask.io/)). **NOTE:** FOR DEVELOPMENT, PLEASE USE A KEY THAT DOESN'T HAVE ANY REAL FUNDS ASSOCIATED WITH IT.
  - You can [learn how to export it here](https://metamask.zendesk.com/hc/en-us/articles/360015289632-How-to-Export-an-Account-Private-Key).
- `SEPOLIA_RPC_URL`: This is url of the sepolia testnet node you're working with. You can get setup with one for free from [Alchemy](https://alchemy.com/?a=673c802981)

Optionally, add your `ETHERSCAN_API_KEY` if you want to verify your contract on [Etherscan](https://etherscan.io/).

2. Get testnet ETH

Head over to [faucets.chain.link](https://faucets.chain.link/) and get some testnet ETH. You should see the ETH show up in your metamask.

3. Deploy

```
make deploy ${--network sepolia}
```

## Estimate gas

You can estimate how much gas things cost by running:

```
forge snapshot
```

And you'll see an output file called `.gas-snapshot`


# Formatting


To run code formatting:
```
forge fmt
```


# Thank you!

If you appreciated this, feel free to follow me or donate!

ETH/Arbitrum/Optimism/Polygon/etc Address: 0x9680201d9c93d65a3603d2088d125e955c73BD65

[![Patrick Collins Twitter](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/PatrickAlphaC)
[![Patrick Collins YouTube](https://img.shields.io/badge/YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/channel/UCn-3f8tw_E1jZvhuHatROwA)
[![Patrick Collins Linkedin](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/patrickalphac/)
[![Patrick Collins Medium](https://img.shields.io/badge/Medium-000000?style=for-the-badge&logo=medium&logoColor=white)](https://patrickalphac.medium.com/)

<!-- Testing krunchdata https://kdta.io/b6T40  -->

