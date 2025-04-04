# Eco-Friendly Cup DeFi Verification System - Contract Functions and Events Reference

This document provides a reference for smart contract functions and events in the Eco-Friendly Cup DeFi Verification System, for frontend developers using the Wagmi library for integration.

## Table of Contents
1. [Smart Contract Addresses](#smart-contract-addresses)
2. [StakingPool Contract](#stakingpool-contract)
3. [VerificationRegistry Contract](#verificationregistry-contract)
4. [RewardController Contract](#rewardcontroller-contract)
5. [EcoCupToken Contract](#ecocuptoken-contract)
6. [Common Use Cases](#common-use-cases)

## Smart Contract Addresses

Below are the deployed smart contract addresses (Base Sepolia Testnet):

- EcoCupToken: `0xAc45De6353970462389974f1b4Cd1712D51c1983`
- VerificationRegistry: `0x6d8030ADb227128a24EB5a189743B670295172e7`
- RewardController: `0x5F0e11b566EC40feCb3Cbab69471fc6E898fF78B`
- StakingPool: `0x435b529860C12Dd35A3255BDbf222450E485aE35`

## StakingPool Contract

### Callable Functions

#### stake
- **Description**: Users stake ETH in the pool to gain verification eligibility
- **Parameters**: None (but requires sending ETH)
- **Returns**: None
- **Notes**:
  - Sent ETH must be >= 0.0001 ETH (MIN_STAKE_AMOUNT)
  - Write operation, requires signature

#### withdraw
- **Description**: Withdraw previously staked ETH
- **Parameters**:
  - `amount` (uint256) - Amount of ETH to withdraw (in Wei)
- **Returns**: None
- **Notes**:
  - User cannot withdraw more than their staked amount
  - Write operation, requires signature

#### getStakedAmount
- **Description**: Get the staked amount for a specified user
- **Parameters**:
  - `user` (address) - User address
- **Returns**:
  - `uint256` - Amount of ETH staked by user (in Wei)
- **Notes**:
  - Read-only operation, no signature required

### Events

#### Staked
- **Description**: Triggered when a user successfully stakes ETH
- **Parameters**:
  - `user` (address indexed) - Address of the staking user
  - `amount` (uint256) - Amount of ETH staked

#### Withdrawn
- **Description**: Triggered when a user successfully withdraws ETH
- **Parameters**:
  - `user` (address indexed) - Address of the withdrawing user
  - `amount` (uint256) - Amount of ETH withdrawn

## VerificationRegistry Contract

### Callable Functions

#### recordVerification
- **Description**: Record a user's completion of an eco-friendly cup usage verification
- **Parameters**:
  - `user` (address) - Address of the user completing verification
- **Returns**: None
- **Notes**:
  - Only addresses with VERIFIER_ROLE can call this
  - Write operation, requires signature

#### canClaimReward
- **Description**: Check if a user can claim today's reward
- **Parameters**:
  - `user` (address) - User address
- **Returns**:
  - `bool` - Whether reward can be claimed
- **Notes**:
  - User must complete 3 verifications today and not yet claimed today's reward
  - Read-only operation, no signature required

#### getVerificationCount
- **Description**: Get user's verification count for today
- **Parameters**:
  - `user` (address) - User address
- **Returns**:
  - `uint32` - Number of verifications completed today
- **Notes**:
  - Read-only operation, no signature required

#### userVerifications
- **Description**: Get detailed verification status for a user
- **Parameters**:
  - `user` (address) - User address
- **Returns**:
  - Struct (uint256 date, uint32 count, bool rewardClaimed)
    - `date` - Date of most recent verification (in days)
    - `count` - Verification count for the day
    - `rewardClaimed` - Whether reward has been claimed
- **Notes**:
  - Read-only operation, no signature required

### Events

#### VerificationRecorded
- **Description**: Triggered when a user's verification is successfully recorded
- **Parameters**:
  - `user` (address indexed) - User address
  - `date` (uint256) - Verification date (in days)
  - `count` (uint32) - Cumulative verification count for the day

#### RewardClaimed
- **Description**: Triggered when a user successfully claims a reward
- **Parameters**:
  - `user` (address indexed) - User address
  - `date` (uint256) - Date of reward claim (in days)

## RewardController Contract

### Callable Functions

#### calculateReward
- **Description**: Calculate the reward amount a user can receive
- **Parameters**:
  - `user` (address) - User address
- **Returns**:
  - `uint256` - Amount of reward tokens that can be received
- **Notes**:
  - Reward based on user's staked ETH amount and current APR
  - Read-only operation, no signature required

#### distributeReward
- **Description**: Distribute reward tokens to a user
- **Parameters**:
  - `user` (address) - Address of the reward recipient
- **Returns**:
  - `uint256` - Amount of reward tokens distributed
- **Notes**:
  - User must complete 3 verifications today and not yet claimed today's reward
  - Write operation, requires signature

#### dailyAPR
- **Description**: Get the current daily APR value
- **Parameters**: None
- **Returns**:
  - `uint256` - Daily APR value (base 10000)
- **Notes**:
  - For example, return value 500 means 5.00%
  - Read-only operation, no signature required

### Events

#### RewardDistributed
- **Description**: Triggered when a user successfully claims rewards
- **Parameters**:
  - `user` (address indexed) - User address
  - `amount` (uint256) - Amount of reward tokens

## EcoCupToken Contract

### Callable Functions

#### balanceOf (ERC-20 Standard Function)
- **Description**: Get token balance for specified address
- **Parameters**:
  - `account` (address) - Address to query balance for
- **Returns**:
  - `uint256` - Token balance
- **Notes**:
  - Read-only operation, no signature required

#### transfer (ERC-20 Standard Function)
- **Description**: Transfer tokens to specified address
- **Parameters**:
  - `to` (address) - Recipient address
  - `amount` (uint256) - Amount of tokens to transfer
- **Returns**:
  - `bool` - Success status
- **Notes**:
  - Write operation, requires signature

#### mint
- **Description**: Mint tokens to specified address
- **Parameters**:
  - `to` (address) - Address to receive tokens
  - `amount` (uint256) - Amount of tokens to mint
- **Returns**: None
- **Notes**:
  - Only addresses with MINTER_ROLE can call this
  - Write operation, requires signature

### Events

#### Transfer (ERC-20 Standard Event)
- **Description**: Triggered when tokens are transferred
- **Parameters**:
  - `from` (address indexed) - Address of the sender
  - `to` (address indexed) - Address of the recipient
  - `value` (uint256) - Amount of tokens transferred

## Common Use Cases

### Case 1: User stakes ETH and performs verification

1. User connects wallet
2. User stakes ETH in StakingPool (call `stake` function)
3. User uses eco-friendly cup and uploads photo for verification
4. Check user's verification count for today (call `getVerificationCount` function)
5. If user completes 3 verifications, user can claim reward

### Case 2: Check user verification progress and reward status

1. Get user's verification count for today (call `getVerificationCount` function)
2. Check if user can claim reward (call `canClaimReward` function)
3. Calculate user's reward amount (call `calculateReward` function)
4. Display user's token balance (call `balanceOf` function)

### Case 3: Claim reward

1. Check if user can claim reward (call `canClaimReward` function)
2. Call `distributeReward` function to distribute reward
3. Listen to `RewardDistributed` event to confirm reward distribution success
4. Update user's token balance (call `balanceOf` function)

### Case 4: Withdraw staked ETH

1. Get user's staked amount (call `getStakedAmount` function)
2. User specifies amount to withdraw
3. Call `withdraw` function to withdraw ETH
4. Listen to `Withdrawn` event to confirm withdrawal success

## Wagmi Usage Notes

When interacting with these contracts using Wagmi library, please note:

1. All amounts should be considered in terms of ETH's 18 decimal places
2. User must complete 3 verifications daily to claim reward
3. Platform token (EcoCupToken) minting can only be executed by RewardController contract
4. Verification records can only be called by addresses with VERIFIER_ROLE
5. Minimum staked amount is 0.0001 ETH
6. Reward calculation based on user's staked ETH amount and current APR
7. Default APR is 5% (represented as 500 in base 10000)

### Contract ABI

You can also view verified contract ABI on BaseScan:
- EcoCupToken: [https://sepolia.basescan.org/address/0xAc45De6353970462389974f1b4Cd1712D51c1983](https://sepolia.basescan.org/address/0xAc45De6353970462389974f1b4Cd1712D51c1983)
- VerificationRegistry: [https://sepolia.basescan.org/address/0x6d8030ADb227128a24EB5a189743B670295172e7](https://sepolia.basescan.org/address/0x6d8030ADb227128a24EB5a189743B670295172e7)
- RewardController: [https://sepolia.basescan.org/address/0x5F0e11b566EC40feCb3Cbab69471fc6E898fF78B](https://sepolia.basescan.org/address/0x5F0e11b566EC40feCb3Cbab69471fc6E898fF78B)
- StakingPool: [https://sepolia.basescan.org/address/0x435b529860C12Dd35A3255BDbf222450E485aE35](https://sepolia.basescan.org/address/0x435b529860C12Dd35A3255BDbf222450E485aE35) 