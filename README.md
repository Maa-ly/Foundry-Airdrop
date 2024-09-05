# Merkle Airdrop

This project consists of two main components:
1. **BagelToken**: A custom ERC20 token with minting functionality.
2. **MerkleAirdrop**: A contract to manage token distribution through a Merkle tree-based airdrop.

## Overview

- The **MerkleAirdrop** contract allows eligible users to claim a predetermined amount of BagelToken based on their inclusion in a Merkle tree.
- The **BagelToken** is an ERC20 token that can be minted by the owner and distributed to users via the airdrop contract.

## Prerequisites

To work with this project, you will need the following:
- [Node.js](https://nodejs.org/) and npm installed.
- [Foundry](https://getfoundry.sh/) for compiling and deploying smart contracts.
- [zkSync CLI](https://zksync.io/) for interacting with zkSync.
- Install the following dependencies in your project:
  ```bash
  murky/=lib/murky/
  @openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/
  foundry-devops/=lib/foundry-devops
  forge-std/=lib/forge-std/src/

git clone https://github.com/Maa-ly/Foundry-Airdrop.git
cd Foundry-Airdrop

