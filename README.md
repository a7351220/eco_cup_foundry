# EcoCup DeFi Verification System

A Foundry-based implementation of the Eco-Friendly Cup DeFi Verification System, which incentivizes eco-friendly behavior through blockchain technology.

## Smart Contract Addresses (Base Sepolia Testnet)

- EcoCupToken: `0xAc45De6353970462389974f1b4Cd1712D51c1983`
- VerificationRegistry: `0x6d8030ADb227128a24EB5a189743B670295172e7`
- RewardController: `0x5F0e11b566EC40feCb3Cbab69471fc6E898fF78B`
- StakingPool: `0x435b529860C12Dd35A3255BDbf222450E485aE35`

## System Overview

The EcoCup DeFi system consists of four main smart contracts:

1. **StakingPool**: Manages user ETH staking with a minimum requirement of 0.0001 ETH
2. **VerificationRegistry**: Tracks user verifications and manages verifier permissions
3. **RewardController**: Handles reward calculations and distributions based on staking and verifications
4. **EcoCupToken**: ERC20 token contract for platform rewards

## Key Features

- ETH staking mechanism
- Daily verification tracking
- Reward distribution based on staked amount
- Role-based access control for verifiers
- Daily APR-based reward calculation (default 5%)

## Contract Verification

Verified contracts can be viewed on BaseScan:
- [EcoCupToken](https://sepolia.basescan.org/address/0xAc45De6353970462389974f1b4Cd1712D51c1983)
- [VerificationRegistry](https://sepolia.basescan.org/address/0x6d8030ADb227128a24EB5a189743B670295172e7)
- [RewardController](https://sepolia.basescan.org/address/0x5F0e11b566EC40feCb3Cbab69471fc6E898fF78B)
- [StakingPool](https://sepolia.basescan.org/address/0x435b529860C12Dd35A3255BDbf222450E485aE35)

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

Deploy to Base Sepolia testnet:

```sh
$ forge script script/DeployEcoCup.s.sol --rpc-url $BASE_SEPOLIA_RPC_URL --broadcast --verify -vvvv
```

## Integration Guide

For detailed integration instructions and API references, please refer to the [Frontend Integration Guide](./intro/frontend-integration-guide.md).

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
