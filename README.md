# CupFi DeFi Verification System

A comprehensive blockchain system that incentivizes eco-friendly behavior through verifiable cup usage tracking, staking mechanisms, and reward distribution. Built using Foundry, the system features identity verification through Self protocol and a scalable architecture for sustainable rewards on the Celo blockchain.

## Contract Addresses

### Celo Mainnet

- CupFiToken: `0xcf9E16Da624FD6A2F7954ff041C7F250473FB6B3`
- VerificationRegistry: `0x729fEd5Fa9703923206A7Ca732Bb84BcB00CadE3`
- SelfVerification: `0x79eB256B30902588F79C217bF82C099e22A89798`
- RewardController: `0x645261A2eeE8145CAe16B24ec4163c57992E4b80`
- StakingPool: `0x312aB286ac8108eFE5bf9C6355aA149a364E27bB`

### Celo Alfajores Testnet

- CupFiToken: `0x098C568b8EFd867E089D130504d6CE9218519Dc2`
- VerificationRegistry: `0xF7C7a89e994a96C227E5911326aCdd5324261Fa3`
- SelfVerification: `0x73a166998f24878c7d1Dd55230A9281AAfEb43C8`
- RewardController: `0x3eA8E0860008fE95E22F2fb68728f40918Eed89E`
- StakingPool: `0x6075431B8eB46fc86c100b44eD669766363e76E6`

## System Architecture

The CupFi DeFi system employs a modular architecture with five interconnected smart contracts that work together to create a secure and incentivized verification ecosystem on Celo:

![System Architecture](https://i.imgur.com/example-architecture.png)

### Core Components

1. **SelfVerification Contract**
   - Integrates with the Self protocol for identity verification
   - Validates zero-knowledge proofs for user identities
   - Prevents sybil attacks by ensuring one identity per user
   - Emits verification events when users complete identity verification

2. **VerificationRegistry Contract**
   - Central hub that coordinates the verification process
   - Tracks daily cup usage verifications per user
   - Enforces identity verification requirement before cup verification
   - Implements role-based access control for verifiers
   - Prevents reward gaming by limiting verifications to 3 per day

3. **RewardController Contract**
   - Calculates rewards based on staked amount and configurable APR
   - Distributes CupFiToken rewards to verified users
   - Enforces eligibility rules (3 verifications and not claimed today)
   - Interacts with VerificationRegistry to check eligibility
   - Mints new tokens via CupFiToken contract

4. **StakingPool Contract**
   - Manages user CELO staking with minimum threshold of 0.0001 CELO
   - Provides staking data to RewardController for reward calculations
   - Enables withdrawals with safety mechanisms
   - Issues events for staking and withdrawal actions

5. **CupFiToken Contract**
   - ERC20-compliant token with role-based minting permissions
   - Serves as the reward currency for verified users
   - Implements OpenZeppelin's AccessControl for secure token management

## Functional Flow

1. User completes identity verification through Self protocol (once per user)
2. User stakes CELO in the StakingPool contract (minimum 0.0001 CELO)
3. User performs eco-friendly cup usage and submits for verification
4. Backend verifies submission and calls VerificationRegistry
5. User completes 3 verifications in a single day
6. User claims daily reward based on their staked amount and current APR
7. Rewards are distributed in CupFiToken to the user's wallet

## Key Technical Features

- **Zero-Knowledge Identity Verification**: Using Self protocol to verify identity while preserving privacy
- **Daily Tracking Mechanism**: Time-based verification tracking with reset logic
- **Role-Based Access Control**: Secure permission management for critical functions
- **Reward Calculation Algorithm**: Dynamic APR-based calculation tied to staking amount
- **Gas-Optimized Design**: Efficient storage patterns and minimal state changes
- **Cross-Contract Communication**: Secure inter-contract calls with proper validation
- **Sybil Resistance**: Prevents multiple accounts through identity verification
- **Reusable Verification Components**: Modular design for easy extension
- **Celo Blockchain Integration**: Leveraging Celo's mobile-first, carbon-negative blockchain for sustainability

## Contract Verification

Verified contracts can be viewed on CeloScan:

### Celo Mainnet
- [CupFiToken](https://celoscan.io/address/0xcf9E16Da624FD6A2F7954ff041C7F250473FB6B3)
- [VerificationRegistry](https://celoscan.io/address/0x729fEd5Fa9703923206A7Ca732Bb84BcB00CadE3)
- [SelfVerification](https://celoscan.io/address/0x79eB256B30902588F79C217bF82C099e22A89798)
- [RewardController](https://celoscan.io/address/0x645261A2eeE8145CAe16B24ec4163c57992E4b80)
- [StakingPool](https://celoscan.io/address/0x312aB286ac8108eFE5bf9C6355aA149a364E27bB)

### Celo Alfajores Testnet
- [CupFiToken](https://alfajores.celoscan.io/address/0x098C568b8EFd867E089D130504d6CE9218519Dc2)
- [VerificationRegistry](https://alfajores.celoscan.io/address/0xF7C7a89e994a96C227E5911326aCdd5324261Fa3)
- [SelfVerification](https://alfajores.celoscan.io/address/0x73a166998f24878c7d1Dd55230A9281AAfEb43C8)
- [RewardController](https://alfajores.celoscan.io/address/0x3eA8E0860008fE95E22F2fb68728f40918Eed89E)
- [StakingPool](https://alfajores.celoscan.io/address/0x6075431B8eB46fc86c100b44eD669766363e76E6)

## Development

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation.html)
- [Node.js](https://nodejs.org/en/) (for dependency management)

### Installation

```sh
$ git clone https://github.com/a7351220/eco_cup_foundry.git
$ cd eco_cup_foundry
$ forge install
$ bun install # or npm install
```

### Build

```sh
$ forge build
```

### Test

```sh
$ forge test
```

### Deploy

Deploy to Celo network:

```sh
# Deploy to Celo Mainnet
$ forge script script/DeployCupFi.s.sol --rpc-url $CELO_MAINNET_RPC_URL --broadcast --verify -vvvv

# Deploy to Celo Alfajores Testnet
$ forge script script/DeployCupFi.s.sol --rpc-url $CELO_ALFAJORES_RPC_URL --broadcast --verify -vvvv
```

## Integration Guide

For detailed integration instructions, API reference, and frontend implementation examples, please refer to the [Frontend Integration Guide](./intro/frontend-integration-guide.md).

## License

This project is licensed under MIT.

## Badges

[![Open in Gitpod][gitpod-badge]][gitpod] [![Github Actions][gha-badge]][gha] [![Foundry][foundry-badge]][foundry] [![License: MIT][license-badge]][license]

[gitpod]: https://gitpod.io/#https://github.com/a7351220/eco_cup_foundry
[gitpod-badge]: https://img.shields.io/badge/Gitpod-Open%20in%20Gitpod-FFB45B?logo=gitpod
[gha]: https://github.com/a7351220/eco_cup_foundry/actions
[gha-badge]: https://github.com/a7351220/eco_cup_foundry/actions/workflows/ci.yml/badge.svg
[foundry]: https://getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg
[license]: https://opensource.org/licenses/MIT
[license-badge]: https://img.shields.io/badge/License-MIT-blue.svg
